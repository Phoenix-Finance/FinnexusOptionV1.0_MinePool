pragma solidity =0.5.16;
import "./TokenConverterData.sol";
import "../modules/SafeMath.sol";
import "../ERC20/IERC20.sol";


/**
 * @title FPTCoin is finnexus collateral Pool token, implement ERC20 interface.
 * @dev ERC20 token. Its inside value is collatral pool net worth.
 *
 */
contract TokenConverter is TokenConverterData {
    using SafeMath for uint256;
    

    function initialize() onlyOwner public {
        
    }
    
    function update() onlyOwner public{
    }
    
    /**
     * @dev constructor function. set FNX minePool contract address. 
     */ 
    function setParameter(address _cfnxAddress,address _fnxAddress,uint256 _timeSpan,uint256 _dispatchTimes,uint256 _txNum) onlyOwner public{
        if (_cfnxAddress != address(0))
            cfnxAddress = _cfnxAddress;
            
        if (_fnxAddress != address(0))
            fnxAddress = _fnxAddress;
            
        if (_timeSpan != 0) 
            timeSpan = _timeSpan;
            
        if (_dispatchTimes != 0) 
            dispatchTimes = _dispatchTimes;
        
        if (_txNum != 0) 
            txNum = _txNum;   
        
    }
    
    /**
     * @dev getting back the left mine token
     * @param reciever the reciever for getting back mine token
     */
    function getbackLeftFnx(address reciever)  public onlyOwner {
        uint256 bal =  IERC20(fnxAddress).balanceOf(address(this));
        IERC20(fnxAddress).transfer(reciever,bal);
    }  

    /**
     * @dev Retrieve user's locked balance. 
     * @param account user's account.
     */ 
    function lockedBalanceOf(address account) public view returns (uint256) {
        return lockedBalances[account];
    }


    function inputCfnxForInstallmentPay(uint256 amount) external {
        require(amount>0);
        
        IERC20(cfnxAddress).transferFrom(tx.origin,address(this),amount);
        uint256 idx = lockedIndexs[tx.origin].totalIdx;
        uint256 divAmount = amount.div(dispatchTimes);

        lockedAllRewards[tx.origin][idx] = lockedReward(now,amount);
        
        //index 0 to save the left token num
        lockedAllRewards[tx.origin][idx].alloc[0] = amount.sub(divAmount);
        uint256 i=2;
        //idx = 1, the reward give user immediately
        for(;i<dispatchTimes;i++){
            lockedAllRewards[tx.origin][idx].alloc[i] = divAmount;
        }
        lockedAllRewards[tx.origin][idx].alloc[i] = amount.sub(divAmount.mul(dispatchTimes-1));
        
        
        lockedBalances[tx.origin] = lockedBalances[tx.origin].add(amount.sub(divAmount));
        
        //should can not be overflow
        lockedIndexs[tx.origin].totalIdx =  lockedIndexs[tx.origin].totalIdx + 1;
        
        IERC20(fnxAddress).transfer(tx.origin,divAmount);
        
    }
    
    
    function claimFnxExpiredReward() external {
        uint256 txcnt = 0;
        uint256 i = lockedIndexs[tx.origin].beginIdx;
        uint256 endIdx = lockedIndexs[tx.origin].totalIdx;
        uint256 totalRet = 0;
        
        for(;i<endIdx && txcnt<txNum;i++) {
           //only count the rewards over at least one timeSpan
           if (now >= lockedAllRewards[tx.origin][i].startTime + timeSpan) {
               
               if (lockedAllRewards[tx.origin][i].alloc[0] > 0) {
                    if (now >= lockedAllRewards[tx.origin][i].startTime + lockPeriod) {
                        totalRet = totalRet.add(lockedAllRewards[tx.origin][i].alloc[0]);
                        lockedAllRewards[tx.origin][i].alloc[0] = 0;
                        
                        //updated last expired idx
                        lockedIndexs[tx.origin].beginIdx = i;
                    } else {
                      
                        uint256 timeIdx = (now - lockedAllRewards[tx.origin][i].startTime).div(timeSpan) + 1;
                        uint256 j = 2;
                        uint256 subtotal = 0;
                        for(;j<timeIdx+1;j++) {
                            subtotal = subtotal.add(lockedAllRewards[tx.origin][i].alloc[j]);
                            lockedAllRewards[tx.origin][i].alloc[j] = 0;
                        }
                        
                        //updated left locked balance
                        lockedAllRewards[tx.origin][i].alloc[0] = lockedAllRewards[tx.origin][i].alloc[0].sub(subtotal);
                        totalRet = totalRet.add(subtotal);
                    }
                    
                    txcnt = txcnt + 1;
               }
                
           } else {
               //the item after this one is pushed behind this,not needed to caculate
               break;
           }
        }
        
        lockedBalances[tx.origin] = lockedBalances[tx.origin].sub(totalRet);
        //transfer back to user
        IERC20(fnxAddress).transfer(tx.origin,totalRet);
    }
    
}
