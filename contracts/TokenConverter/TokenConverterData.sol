pragma solidity =0.5.16;

import "../modules/Managerable.sol";

contract TokenConverterData is Managerable {

    struct lockedReward {
        uint256 startTime;
        uint256 total;
        mapping (uint256 => uint256) alloc;
    }
    
    struct lockedIdx {
        uint256 beginIdx;
        uint256 totalIdx;
    }
    
    address public cfnxAddress;
    address public fnxAddress;
    uint256 public timeSpan = 30*24*3600;//one month
    uint256 public dispatchTimes = 6;    //6 times
    uint256 public txNum = 100; //100 times transfer tx 
    uint256 public lockPeriod = 6*timeSpan;
    
    //the user's locked total balance
    mapping (address => uint256) public lockedBalances;
    
    mapping (address =>  mapping (uint256 => lockedReward)) public lockedAllRewards;
    
    mapping (address => lockedIdx) public lockedIndexs;
    
    
    /**
     * @dev Emitted when `owner` locked  `amount` FPT, which net worth is  `worth` in USD. 
     */
    event AddLocked(address indexed owner, uint256 amount,uint256 worth);
    /**
     * @dev Emitted when `owner` burned locked  `amount` FPT, which net worth is  `worth` in USD. 
     */
    event BurnLocked(address indexed owner, uint256 amount,uint256 worth);

}