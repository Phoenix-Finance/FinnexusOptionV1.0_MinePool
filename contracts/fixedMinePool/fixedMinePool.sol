pragma solidity =0.5.16;
/**
 * SPDX-License-Identifier: GPL-3.0-or-later
 * FinNexus
 * Copyright (C) 2020 FinNexus Options Protocol
 */
import "../modules/SafeMath.sol";
import "./fixedMinePoolData.sol";
import "../ERC20/IERC20.sol";
/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract fixedMinePool is fixedMinePoolData {
    using SafeMath for uint256;
    constructor(address FPTA,address FPTB,address USDC,uint256 startTime)public{
        _FPTA = FPTA;
        _FPTB = FPTB;
        _premium = USDC;
        _startTime = startTime;
        initialize();
    }
    /**
     * @dev default function for foundation input miner coins.
     */
    function()external payable{

    }
    function initialize() initializer public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        _flexibleExpired = 15 days;
    }
    function setAddresses(address FPTA,address FPTB,address USDC,uint256 startTime) public onlyOwner {
        _FPTA = FPTA;
        _FPTB = FPTB;
        _premium = USDC;
        _startTime = startTime;
    }
    function setFPTAAddress(address FPTA)onlyOwner public {
        _FPTA = FPTA;
    }
    function setFPTBAddress(address FPTB)onlyOwner public {
        _FPTB = FPTB;
    }
    function getFPTAAddress()public view returns (address) {
        return _FPTA;
    }
    function getFPTBAddress()public view returns (address) {
        return _FPTB;
    }
    function setStartTime(uint256 startTime)onlyOwner public {
        _startTime = startTime;
    }
    function getStartTime()public view returns (uint256) {
        return _startTime;
    }
    function getCurrentPeriodID()public view returns (uint256) {
        return getPeriodIndex(currentTime());
    }
    function getUserFPTABalance(address account)public view returns (uint256) {
        return userInfoMap[account]._FPTABalance;
    }
    function getUserFPTBBalance(address account)public view returns (uint256) {
        return userInfoMap[account]._FPTBBalance;
    }
    function getUserMaxPeriodId(address account)public view returns (uint256) {
        return userInfoMap[account].maxPeriodID;
    }
    function getUserExpired(address account)public view returns (uint256) {
        return userInfoMap[account].lockedExpired;
    }
    /**
     * @dev foundation redeem out mine coins.
     * @param mineCoin mineCoin address
     * @param amount redeem amount.
     */
    function redeemOut(address mineCoin,uint256 amount)public onlyOwner{
        _redeem(msg.sender,mineCoin,amount);
    }
    function _redeem(address payable recieptor,address mineCoin,uint256 amount) internal{
        if (mineCoin == address(0)){
            recieptor.transfer(amount);
        }else{
            IERC20 token = IERC20(mineCoin);
            uint256 preBalance = token.balanceOf(address(this));
            token.transfer(recieptor,amount);
            uint256 afterBalance = token.balanceOf(address(this));
            require(preBalance - afterBalance == amount,"settlement token transfer error!");
        }
    }
    /**
     * @dev retrieve total distributed mine coins.
     * @param mineCoin mineCoin address
     */
    function getTotalMined(address mineCoin)public view returns(uint256){
        return mineInfoMap[mineCoin].totalMinedCoin.add(_getLatestMined(mineCoin));
    }
    /**
     * @dev retrieve minecoin distributed informations.
     * @param mineCoin mineCoin address
     * @return distributed amount and distributed time interval.
     */
    function getMineInfo(address mineCoin)public view returns(uint256,uint256){
        return (mineInfoMap[mineCoin].mineAmount,mineInfoMap[mineCoin].mineInterval);
    }
    /**
     * @dev retrieve user's mine balance.
     * @param account user's account
     * @param mineCoin mineCoin address
     */
    function getMinerBalance(address account,address mineCoin)public view returns(uint256){
        return userInfoMap[account].minerBalances[mineCoin].add(_getUserLatestMined(mineCoin,account));
    }
    /**
     * @dev Set mineCoin mine info, only foundation owner can invoked.
     * @param mineCoin mineCoin address
     * @param _mineAmount mineCoin distributed amount
     * @param _mineInterval mineCoin distributied time interval
     */
    function setMineCoinInfo(address mineCoin,uint256 _mineAmount,uint256 _mineInterval)public onlyOwner {
        require(_mineAmount<1e30,"input mine amount is too large");
        require(_mineInterval>0,"input mine Interval must larger than zero");
        _mineSettlement(mineCoin);
        mineInfoMap[mineCoin].mineAmount = _mineAmount;
        mineInfoMap[mineCoin].mineInterval = _mineInterval;
        if (mineInfoMap[mineCoin].startPeriod == 0){
            mineInfoMap[mineCoin].startPeriod = getPeriodIndex(currentTime());
        }
        addWhiteList(mineCoin);
    }

    /**
     * @dev user redeem mine rewards.
     * @param mineCoin mine coin address
     * @param amount redeem amount.
     */
    function redeemMinerCoin(address mineCoin,uint256 amount)public nonReentrant notHalted {
        _mineSettlement(mineCoin);
        _settleUserMine(mineCoin,msg.sender);
        _redeemMineCoin(mineCoin,msg.sender,amount);
    }
    /**
     * @dev subfunction for user redeem mine rewards.
     * @param mineCoin mine coin address
     * @param recieptor recieptor's account
     * @param amount redeem amount.
     */
    function _redeemMineCoin(address mineCoin,address payable recieptor,uint256 amount) internal {
        require (amount > 0,"input amount must more than zero!");
        userInfoMap[recieptor].minerBalances[mineCoin] = 
            userInfoMap[recieptor].minerBalances[mineCoin].sub(amount);
        _redeem(recieptor,mineCoin,amount);
        emit RedeemMineCoin(recieptor,mineCoin,amount);
    }

    /**
     * @dev settle all mine coin.
     */    
    function _mineSettlementAll()internal{
        uint256 addrLen = whiteList.length;
        for(uint256 i=0;i<addrLen;i++){
            _mineSettlement(whiteList[i]);
        }
    }
    function getPeriodIndex(uint256 _time) public view returns (uint256) {
        if (_time<_startTime){
            return 0;
        }
        return _time.sub(_startTime).div(_period)+1;
    }
    function getPeriodFinishTime(uint256 periodID)public view returns (uint256) {
        return periodID.mul(_period).add(_startTime);
    }
    /**
     * @dev the auxiliary function for _mineSettlementAll.
     */    
    function _mineSettlement(address mineCoin)internal{
        uint256 latestTime = mineInfoMap[mineCoin].latestSettleTime;
        uint256 curIndex = getPeriodIndex(latestTime);
        uint256 nowIndex = getPeriodIndex(currentTime());
        for (uint256 i=0;i<_maxLoop;i++){
            // If the fixed distribution is zero, we only need calculate 
            uint256 finishTime = getPeriodFinishTime(curIndex);
            if (finishTime < currentTime()){
                _mineSettlementPeriod(mineCoin,curIndex,finishTime.sub(latestTime));
                latestTime = finishTime;
            }else{
                _mineSettlementPeriod(mineCoin,curIndex,currentTime().sub(latestTime));
                latestTime = currentTime();
                break;
            }
            curIndex++;
            if (curIndex > nowIndex){
                break;
            }
        }
        mineInfoMap[mineCoin].periodMinedNetWorth[nowIndex] = mineInfoMap[mineCoin].minedNetWorth;
        uint256 _mineInterval = mineInfoMap[mineCoin].mineInterval;
        if (_mineInterval>0){
            mineInfoMap[mineCoin].latestSettleTime = currentTime()/_mineInterval*_mineInterval;
        }else{
            mineInfoMap[mineCoin].latestSettleTime = currentTime();
        }
    }
    function _mineSettlementPeriod(address mineCoin,uint256 periodID,uint256 mineTime)internal{
        uint256 totalDistri = totalDistribution;
        if (totalDistri > 0){
            uint256 latestMined = _getPeriodMined(mineCoin,periodID,mineTime);
            if (latestMined>0){
                mineInfoMap[mineCoin].minedNetWorth = mineInfoMap[mineCoin].minedNetWorth.add(latestMined.mul(calDecimals)/totalDistri);
                mineInfoMap[mineCoin].totalMinedCoin = mineInfoMap[mineCoin].totalMinedCoin.add(latestMined.mul(
                    getweightDistribution(periodID))/totalDistri);
            }
        }
        mineInfoMap[mineCoin].periodMinedNetWorth[periodID] = mineInfoMap[mineCoin].minedNetWorth;
    }
    function _settleUserMine(address mineCoin,address account) internal {
        uint256 nowIndex = getPeriodIndex(currentTime());
        if(userInfoMap[account].distribution>0){
            uint256 userPeriod = userInfoMap[account].settlePeriod[mineCoin];
            if (userPeriod < mineInfoMap[mineCoin].startPeriod){
                userPeriod = mineInfoMap[mineCoin].startPeriod;
            }
            
            for (uint256 i = 0;i<_maxLoop;i++){
                _settlementPeriod(mineCoin,account,userPeriod);
                if (userPeriod >= nowIndex){
                    break;
                }
                userPeriod++;
            }
        }
        userInfoMap[account].minerOrigins[mineCoin] = _getTokenNetWorth(mineCoin,nowIndex);
        userInfoMap[account].settlePeriod[mineCoin] = nowIndex;
    }
    function _settlementPeriod(address mineCoin,address account,uint256 periodID) internal {
        uint256 tokenNetWorth = _getTokenNetWorth(mineCoin,periodID);
        if (totalDistribution > 0){
            userInfoMap[account].minerBalances[mineCoin] = userInfoMap[account].minerBalances[mineCoin].add(
                _settlement(mineCoin,account,periodID,tokenNetWorth));
        }
        userInfoMap[account].minerOrigins[mineCoin] = tokenNetWorth;
    }
    function _getTokenNetWorth(address mineCoin,uint256 periodID)internal view returns(uint256){
        return mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
    }

    /**
     * @dev the auxiliary function for _mineSettlementAll. Calculate latest time phase distributied mine amount.
     */ 
    function _getUserLatestMined(address mineCoin,address account)internal view returns(uint256){
        uint256 userDistri = userInfoMap[account].distribution;
        if (userDistri == 0){
            return 0;
        }
        uint256 userperiod = userInfoMap[account].settlePeriod[mineCoin];
        if (userperiod < mineInfoMap[mineCoin].startPeriod){
            userperiod = mineInfoMap[mineCoin].startPeriod;
        }
        uint256 origin = userInfoMap[account].minerOrigins[mineCoin];
        uint256 latestMined = 0;
        uint256 nowIndex = getPeriodIndex(currentTime());
        uint256 userMaxPeriod = userInfoMap[account].maxPeriodID;
        uint256 netWorth = _getTokenNetWorth(mineCoin,userperiod);

        for (uint256 i=0;i<_maxLoop;i++){
            if(userperiod > nowIndex){
                break;
            }
            if (totalDistribution == 0){
                break;
            }
            netWorth = getPeriodNetWorth(mineCoin,userperiod,netWorth);
            latestMined = latestMined.add(userDistri.mul(netWorth.sub(origin)).mul(getPeriodWeight(userperiod,userMaxPeriod))/1000/calDecimals);
            origin = netWorth;
            userperiod++;
        }
        return latestMined;
    }
    function getPeriodNetWorth(address mineCoin,uint256 periodID,uint256 preNetWorth) internal view returns(uint256) {
        uint256 latestTime = mineInfoMap[mineCoin].latestSettleTime;
        uint256 curPeriod = getPeriodIndex(latestTime);
        if(periodID < curPeriod){
            return mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
        }else{
            if (preNetWorth<mineInfoMap[mineCoin].periodMinedNetWorth[periodID]){
                preNetWorth = mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
            }
            uint256 finishTime = getPeriodFinishTime(periodID);
            if (finishTime >= currentTime()){
                finishTime = currentTime();
            }
            if(periodID > curPeriod){
                latestTime = getPeriodFinishTime(periodID-1);
            }
            if (totalDistribution == 0){
                return preNetWorth;
            }
            uint256 periodMind = _getPeriodMined(mineCoin,periodID,finishTime.sub(latestTime));
            return preNetWorth.add(periodMind.mul(calDecimals)/totalDistribution);
        }
    }
    /**
     * @dev the auxiliary function for _mineSettlementAll. Calculate latest time phase distributied mine amount.
     */ 
    function _getLatestMined(address mineCoin)internal view returns(uint256){
        uint256 latestTime = mineInfoMap[mineCoin].latestSettleTime;
        uint256 curIndex = getPeriodIndex(latestTime);
        uint256 latestMined = 0;
        for (uint256 i=0;i<_maxLoop;i++){
            if (totalDistribution == 0){
                break;
            }
            uint256 finishTime = getPeriodFinishTime(curIndex);
            if (finishTime < currentTime()){
                latestMined = latestMined.add(_getPeriodWeightMined(mineCoin,curIndex,finishTime.sub(latestTime)));
            }else{
                latestMined = latestMined.add(_getPeriodWeightMined(mineCoin,curIndex,currentTime().sub(latestTime)));
                break;
            }
            curIndex++;
            latestTime = finishTime;
        }
        return latestMined;
    }
    function _getPeriodMined(address mineCoin,uint256 periodID,uint256 mintTime)internal view returns(uint256){
        uint256 _mineInterval = mineInfoMap[mineCoin].mineInterval;
        if (totalDistribution > 0 && _mineInterval>0){
            uint256 _mineAmount = mineInfoMap[mineCoin].mineAmount;
            mintTime = mintTime/_mineInterval;
            uint256 latestMined = _mineAmount.mul(mintTime);
            return latestMined;
        }
        return 0;
    }
    function _getPeriodWeightMined(address mineCoin,uint256 periodID,uint256 mintTime)internal view returns(uint256){
        if (totalDistribution > 0){
            return _getPeriodMined(mineCoin,periodID,mintTime).mul(getweightDistribution(periodID)).div(totalDistribution);
        }
        return 0;
    }
    /**
     * @dev subfunction, settle user's latest mine amount.
     * @param mineCoin the mine coin address
     * @param account user's account
     * @param tokenNetWorth the latest token net worth
     */
    function _settlement(address mineCoin,address account,uint256 periodID,uint256 tokenNetWorth)internal returns (uint256) {
        uint256 origin = userInfoMap[account].minerOrigins[mineCoin];
        uint256 userMaxPeriod = userInfoMap[account].maxPeriodID;
        require(tokenNetWorth>=origin,"error: tokenNetWorth logic error!");
        return userInfoMap[account].distribution.mul(tokenNetWorth-origin).mul(getPeriodWeight(periodID,userMaxPeriod))/1000/calDecimals;
    }
    function stakeFPTA(uint256 amount)public nonReentrant notHalted{
        amount = getPayableAmount(_FPTA,amount);
        require(amount > 0, 'stake amount is zero');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTABalance = userInfoMap[msg.sender]._FPTABalance.add(amount);
        addDistribution(msg.sender);
        emit StakeFPTA(msg.sender,amount);
    }
    function lockAirDrop(address user,uint256 ftp_b_amount) external{
        uint256 curPeriod = getPeriodIndex(currentTime());
        uint256 maxId = userInfoMap[user].maxPeriodID;
        uint256 lockedPeriod = curPeriod+1 > maxId ? curPeriod+1 : maxId;
        ftp_b_amount = getPayableAmount(_FPTB,ftp_b_amount);
        require(ftp_b_amount > 0, 'stake amount is zero');
        removeDistribution(user);
        userInfoMap[user]._FPTBBalance = userInfoMap[user]._FPTBBalance.add(ftp_b_amount);
        userInfoMap[user].maxPeriodID = lockedPeriod;
        addDistribution(user);
        emit LockAirDrop(msg.sender,user,ftp_b_amount);
    }
    function stakeFPTB(uint256 amount,uint256 lockedPeriod)public validPeriod(lockedPeriod) nonReentrant notHalted{
        uint256 curPeriod = getPeriodIndex(currentTime());
        require(curPeriod+lockedPeriod-1>=userInfoMap[msg.sender].maxPeriodID, "lockedPeriod cannot be smaller than current locked period");
        amount = getPayableAmount(_FPTB,amount);
        require(amount > 0, 'stake amount is zero');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTBBalance = userInfoMap[msg.sender]._FPTBBalance.add(amount);
        if (lockedPeriod == 0){
            userInfoMap[msg.sender].maxPeriodID = 0;
        }else{
            userInfoMap[msg.sender].maxPeriodID = curPeriod+lockedPeriod-1;
        }
        addDistribution(msg.sender);
        emit StakeFPTB(msg.sender,amount,lockedPeriod);
    }
    function unstakeFPTA(uint256 amount)public nonReentrant notHalted{
        require(amount > 0, 'unstake amount is zero');
        require(userInfoMap[msg.sender]._FPTABalance >= amount,
            'unstake amount is greater than total user stakes');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTABalance = userInfoMap[msg.sender]._FPTABalance - amount;
        addDistribution(msg.sender);
        _redeem(msg.sender,_FPTA,amount);
        emit UnstakeFPTA(msg.sender,amount);
    }
    function unstakeFPTB(uint256 amount)public nonReentrant notHalted periodExpired(msg.sender){
        require(amount > 0, 'unstake amount is zero');
        require(userInfoMap[msg.sender]._FPTBBalance >= amount,
            'unstake amount is greater than total user stakes');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTBBalance = userInfoMap[msg.sender]._FPTBBalance - amount;
        addDistribution(msg.sender);
        _redeem(msg.sender,_FPTB,amount);
        emit UnstakeFPTB(msg.sender,amount);
    }
    function changeFPTBLockedPeriod(uint256 lockedPeriod)public validPeriod(lockedPeriod) notHalted{
        uint256 curPeriod = getPeriodIndex(currentTime());
        require(curPeriod+lockedPeriod-1>=userInfoMap[msg.sender].maxPeriodID, "lockedPeriod cannot be smaller than current locked period");
        removeDistribution(msg.sender); 
        if (lockedPeriod == 0){
            userInfoMap[msg.sender].maxPeriodID = 0;
        }else{
            userInfoMap[msg.sender].maxPeriodID = curPeriod+lockedPeriod-1;
        }
        addDistribution(msg.sender);
        emit ChangeLockedPeriod(msg.sender,lockedPeriod);
    }

    function getPayableAmount(address settlement,uint256 settlementAmount) internal returns (uint256) {
        if (settlement == address(0)){
            settlementAmount = msg.value;
        }else if (settlementAmount > 0){
            IERC20 oToken = IERC20(settlement);
            uint256 preBalance = oToken.balanceOf(address(this));
            oToken.transferFrom(msg.sender, address(this), settlementAmount);
            uint256 afterBalance = oToken.balanceOf(address(this));
            require(afterBalance-preBalance==settlementAmount,"settlement token transfer error!");
        }
        return settlementAmount;
    }
    function removeDistribution(address account) internal {
        uint256 addrLen = whiteList.length;
        for(uint256 i=0;i<addrLen;i++){
            _mineSettlement(whiteList[i]);
            _settleUserMine(whiteList[i],account);
        }
        uint256 distri = calculateDistribution(account);
        totalDistribution = totalDistribution.sub(distri);
        uint256 nowId = getPeriodIndex(currentTime());
        uint256 endId = userInfoMap[account].maxPeriodID;
        for(;nowId<=endId;nowId++){
            weightDistributionMap[nowId] = weightDistributionMap[nowId].sub(distri.mul(getPeriodWeight(nowId,endId)-1000)/1000);
        }
        userInfoMap[account].distribution =  0;
        removePremiumDistribution(account);
    }
    function addDistribution(address account) internal {
        uint256 distri = calculateDistribution(account);
        if (userInfoMap[account].maxPeriodID == 0){
            //flexible mined
            userInfoMap[account].lockedExpired = currentTime().add(_flexibleExpired);
        }else{
            uint256 nowId = getPeriodIndex(currentTime());
            uint256 endId = userInfoMap[account].maxPeriodID;
            for(;nowId<=endId;nowId++){
                weightDistributionMap[nowId] = weightDistributionMap[nowId].add(distri.mul(getPeriodWeight(nowId,endId)-1000)/1000);
            }
            userInfoMap[account].lockedExpired = getPeriodFinishTime(endId);
        }
        userInfoMap[account].distribution =  distri;
        totalDistribution = totalDistribution.add(distri);
        addPremiumDistribution(account);
    }
    function calculateDistribution(address account) internal view returns (uint256){
        uint256 fptAAmount = userInfoMap[account]._FPTABalance;
        uint256 fptBAmount = userInfoMap[account]._FPTBBalance;
        uint256 repeat = (fptAAmount>fptBAmount) ? fptBAmount : fptAAmount;
        return _FPTARatio.mul(fptAAmount).add(_FPTBRatio.mul(fptBAmount)).add(
            _RepeatRatio.mul(repeat));
    }
    function getweightDistribution(uint256 periodID)internal view returns (uint256) {
        return weightDistributionMap[periodID].add(totalDistribution);
    }
    function getPeriodWeight(uint256 currentID,uint256 maxPeriod) internal pure returns (uint256) {
        if (maxPeriod == 0 || currentID > maxPeriod){
            return 1000;
        }
        return maxPeriod.sub(currentID).mul(periodWeight) +5000;
    }

       /**
     * @dev retrieve total distributed mine coins.
     */
    function getTotalPremium()public view returns(uint256){
        return totalDistributedPremium;
    }

    /**
     * @dev user redeem mine rewards.
     * @param amount redeem amount.
     */
    function redeemPremium(uint256 amount)public nonReentrant notHalted {
        uint256 lastIndex = userLastPremiumIndex[msg.sender];
        uint256 nowIndex = getPeriodIndex(currentTime());
        uint256 endIndex = lastIndex+_maxLoop < distributedPeriod.length ? lastIndex+_maxLoop : distributedPeriod.length;
        uint256 LatestPremium = 0;
        for (; lastIndex< endIndex;lastIndex++){
            uint256 periodID = distributedPeriod[lastIndex];
            if (periodID == nowIndex || premiumMinedMap[periodID].totalPremiumDistribution == 0 ||
                premiumMinedMap[periodID].userPremiumDistribution[msg.sender] == 0){
                continue;
            }
            LatestPremium = LatestPremium.add(premiumMinedMap[periodID].totalMined.mul(premiumMinedMap[periodID].userPremiumDistribution[msg.sender]).div(
                premiumMinedMap[periodID].totalPremiumDistribution));
        }
        userLastPremiumIndex[msg.sender] = endIndex;
        if(LatestPremium > 0){
            _redeem(msg.sender,_premium,amount);
        }
        emit RedeemPremium(msg.sender,amount);
    }


    /**
     * @dev the auxiliary function for _mineSettlementAll. Calculate latest time phase distributied mine amount.
     */ 
    function getUserLatestPremium(address account)public view returns(uint256){
        uint256 lastIndex = userLastPremiumIndex[account];
        uint256 nowIndex = getPeriodIndex(currentTime());
        uint256 endIndex = lastIndex+_maxLoop < distributedPeriod.length ? lastIndex+_maxLoop : distributedPeriod.length;
        uint256 LatestPremium = 0;
        for (; lastIndex< endIndex;lastIndex++){
            uint256 periodID = distributedPeriod[lastIndex];
            if (periodID == nowIndex || premiumMinedMap[periodID].totalPremiumDistribution == 0 ||
                premiumMinedMap[periodID].userPremiumDistribution[account] == 0){
                continue;
            }
            LatestPremium = LatestPremium.add(premiumMinedMap[periodID].totalMined.mul(premiumMinedMap[periodID].userPremiumDistribution[account]).div(
                premiumMinedMap[periodID].totalPremiumDistribution));
        }        
        return LatestPremium;
    }
 

    function distributePremium(uint256 periodID,uint256 amount)public onlyOwner {
        amount = getPayableAmount(_premium,amount);
        require(amount > 0, 'Distribution amount is zero');
        require(premiumMinedMap[periodID].totalMined == 0 , "This period is already distributed!");
        uint256 nowIndex = getPeriodIndex(currentTime());
        require(nowIndex > periodID, 'This period is not finished');
        premiumMinedMap[periodID].totalMined = amount;
        totalDistributedPremium = totalDistributedPremium.add(amount);
        distributedPeriod.push(uint64(periodID));
        emit DistributePremium(msg.sender,periodID,amount);
    }
    function removePremiumDistribution(address account) internal {
        uint256 beginTime = currentTime(); 
        uint256 nowId = getPeriodIndex(beginTime);
        uint256 endId = userInfoMap[account].maxPeriodID;
        uint256 FPTBBalance = userInfoMap[account]._FPTBBalance;
        for(;nowId<endId;nowId++){
            uint256 finishTime = getPeriodFinishTime(nowId);
            uint256 periodDistribution = finishTime.sub(beginTime).mul(FPTBBalance);
            premiumMinedMap[nowId].totalPremiumDistribution = premiumMinedMap[nowId].totalPremiumDistribution.sub(periodDistribution);
            premiumMinedMap[nowId].userPremiumDistribution[account] = premiumMinedMap[nowId].userPremiumDistribution[account].sub(periodDistribution);
            beginTime = finishTime;
        }
    }
    function addPremiumDistribution(address account) internal {
        uint256 beginTime = currentTime(); 
        uint256 nowId = getPeriodIndex(beginTime);
        uint256 endId = userInfoMap[account].maxPeriodID;
        uint256 FPTBBalance = userInfoMap[account]._FPTBBalance;
        for(;nowId<endId;nowId++){
            uint256 finishTime = getPeriodFinishTime(nowId);
            uint256 periodDistribution = finishTime.sub(beginTime).mul(FPTBBalance);
            premiumMinedMap[nowId].totalPremiumDistribution = premiumMinedMap[nowId].totalPremiumDistribution.add(periodDistribution);
            premiumMinedMap[nowId].userPremiumDistribution[account] = premiumMinedMap[nowId].userPremiumDistribution[account].add(periodDistribution);
            beginTime = finishTime;
        }

    }

    modifier periodExpired(address account){
        require(userInfoMap[account].lockedExpired < currentTime(),'locked period is not expired');

        _;
    }
    modifier validPeriod(uint256 period){
        require(period >= 0 && period <= _maxPeriod, 'locked period must be in valid range');
        _;
    }
    function currentTime() internal view returns (uint256){
        return now;
    }
}