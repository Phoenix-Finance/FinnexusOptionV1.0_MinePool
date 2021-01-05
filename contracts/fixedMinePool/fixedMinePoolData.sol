pragma solidity =0.5.16;
/**
 * SPDX-License-Identifier: GPL-3.0-or-later
 * FinNexus
 * Copyright (C) 2020 FinNexus Options Protocol
 */
import "../modules/Halt.sol";
import "../modules/AddressWhiteList.sol";
import "../modules/ReentrancyGuard.sol";
import "../modules/once.sol";
/**
 * @title FPTCoin mine pool, which manager contract is FPTCoin.
 * @dev A smart-contract which distribute some mine coins by FPTCoin balance.
 *
 */
contract fixedMinePoolData is once,Halt,AddressWhiteList,ReentrancyGuard {
    //Special decimals for calculation
    uint256 constant calDecimals = 1e18;

    uint256 internal _startTime;
    uint256 internal constant _period = 90 days;
    uint256 internal _flexibleExpired = 15 days;

    uint256 constant internal _minPeriod = 1; 
    uint256 constant internal _maxPeriod = 12;
    uint256 constant internal _maxLoop = 200;
    uint256 constant internal _FPTARatio = 1000;
    uint256 constant internal _FPTBRatio = 1000;
    uint256 constant internal _RepeatRatio = 20000;
    uint256 constant internal periodWeight = 1000;

    address internal _premium;
    address internal _FPTA;
    address internal _FPTB;

    struct userInfo {
        uint256 _FPTABalance;
        uint256 _FPTBBalance;
        uint256 maxPeriodID;

        mapping(address=>uint256) minerBalances;
        mapping(address=>uint256) minerOrigins;
        //user's max locked period id.
        //user's latest settlement period for each token.
        mapping(address=>uint256) settlePeriod;
        uint256 lockedExpired;
    }
    struct tokenMineInfo {
        uint256 mineAmount;
        uint256 mineInterval;
        uint256 startPeriod;
        uint256 latestSettleTime;
        uint256 totalMinedCoin;
        uint256 minedNetWorth;
        mapping(uint256=>uint256) periodMinedNetWorth;
    }

    mapping(address=>userInfo) internal userInfoMap;
    mapping(address=>tokenMineInfo) internal mineInfoMap;
    mapping(uint256=>uint256) internal totalDistributionMap;
    mapping(uint256=>uint256) internal weightDistributionMap;
    uint256 internal FPTBFlexibleDistribution;
    uint256 internal FPTADistribution;

    struct premiumMined {
        uint256 totalPremiumDistribution;
        mapping(address=>uint256) userPremiumDistribution;
        uint256 totalMined;
    }
    uint64[] internal distributedPeriod;
    uint256 internal totalDistributedPremium;
    mapping(uint256=>premiumMined) internal premiumMinedMap;
    mapping(address=>uint256) internal userLastPremiumIndex;

    /**
     * @dev Emitted when `account` mint `amount` miner shares.
     */
    event MintMiner(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `account` burn `amount` miner shares.
     */
    event BurnMiner(address indexed account,uint256 amount);
    /**
     * @dev Emitted when `from` redeem `value` mineCoins.
     */
    event RedeemMineCoin(address indexed from, address indexed mineCoin, uint256 value);
    /**
     * @dev Emitted when `account` buying options get `amount` mineCoins.
     */
    event BuyingMiner(address indexed account,address indexed mineCoin,uint256 amount);
    event DebugEvent(uint256 indexed value1,uint256 indexed value2,uint256 value3);
}
