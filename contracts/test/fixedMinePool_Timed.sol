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
contract fixedMinePool_Timed is fixedMinePool {
    uint256 _timeAccumulation;
    using SafeMath for uint256;
    constructor(address FPTA,address FPTB,address USDC,uint256 startTime)public fixedMinePool(FPTA,FPTB,USDC,startTime){
        _flexibleExpired = 0;
    }
    function update() public onlyOwner{
        _flexibleExpired = 0;
    }
    function setTime(uint256 _time) public{
        _timeAccumulation = _time;
    }
    function getPeriodWeightDistribution(uint256 periodId) public view returns (uint256){
        return weightDistributionMap[periodId];
    }
    function getUserDistribution(address account) public view returns (uint256){
        return userInfoMap[account].distribution;
    }
    function getDistributionCal(address account) public view returns (uint256){
        return calculateDistribution(account);
    }
    function getTokenNetWorth(address mineCoin,uint256 periodID)public view returns(uint256){
        return mineInfoMap[mineCoin].periodMinedNetWorth[periodID];
    }
    function getUserSettlePeriod(address account,address mineCoin)public view returns(uint256){
        return userInfoMap[account].settlePeriod[mineCoin];
    }
    function getPeriodIndex(uint256 _time) public view returns (uint256) {
        return _time/10+1;
    }
    function getPeriodFinishTime(uint256 periodID)public view returns (uint256) {
        return periodID*10;
    }
    function currentTime() internal view returns (uint256){
        return _timeAccumulation;
    }
}