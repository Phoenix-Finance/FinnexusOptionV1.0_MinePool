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
    function setTime(uint256 _time) public{
        _timeAccumulation = _time;
    }
    function getFPTBFlexibleDistribution() public view returns (uint256){
        return FPTBFlexibleDistribution;
    }
    function getFPTADistribution() public view returns (uint256){
        return FPTADistribution;
    }
    function getCurrentPeriodDistribution() public view returns (uint256){
        uint256 nowId = getPeriodIndex(currentTime());
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