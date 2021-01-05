pragma solidity =0.5.16;
/**
 * SPDX-License-Identifier: GPL-3.0-or-later
 * FinNexus
 * Copyright (C) 2020 FinNexus Options Protocol
 */
import "../modules/SafeMath.sol";
import "../fixedMinePool/fixedMinePool.sol";
/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract fixedMinePool_test is fixedMinePool {
    using SafeMath for uint256;
    constructor(address FPTA,address FPTB,address USDC,uint256 startTime)public fixedMinePool(FPTA,FPTB,USDC,startTime){
    }
    function getFPTBFlexibleDistribution() public view returns (uint256){
        return FPTBFlexibleDistribution;
    }
    function getFPTADistribution() public view returns (uint256){
        return FPTADistribution;
    }
    function getCurrentPeriodDistribution() public view returns (uint256){
        uint256 nowId = getPeriodIndex(now);
        return totalDistributionMap[nowId];
    }
    function getPeriodDistribution(uint256 periodId) public view returns (uint256){
        return totalDistributionMap[periodId];
    }
    function getPeriodWeightDistribution(uint256 periodId) public view returns (uint256){
        return weightDistributionMap[periodId];
    }
    function getUserDistribution(address account,uint256 periodId) public view returns (uint256){
        return userPeriodDistribution(account,periodId);
    }
    function getDistributionCal(address account) public view returns (uint256,uint256){
        return calculateDistribution(account);
    }
    function getTokenNetWorth(address mineCoin,uint256 periodID)public view returns(uint256){
        return mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
    }
    function getUserSettlePeriod(address account,address mineCoin)public view returns(uint256){
        return userInfoMap[account].settlePeriod[mineCoin];
    }
    function unstakeFPTB(uint256 amount)public nonReentrant notHalted{
        require(amount > 0, 'unstake amount is zero');
        require(userInfoMap[msg.sender]._FPTBBalance >= amount,
            'unstake amount is greater than total user stakes');
        removeDistribution(msg.sender);
        userInfoMap[msg.sender]._FPTBBalance = userInfoMap[msg.sender]._FPTBBalance - amount;
        addDistribution(msg.sender);
        _redeem(msg.sender,_FPTB,amount);
    }
}