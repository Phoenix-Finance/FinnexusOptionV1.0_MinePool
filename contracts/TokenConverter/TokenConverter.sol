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
    
    /**
     * @dev constructor function. set FNX minePool contract address. 
     */ 
    function initialize(address _cfnxAddress,address _fnxAddress,uint256 _timeSpan,uint256 _dispatchTimes,uint256 _txNum) onlyOwner public{
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


    function inputCfnxForInstalmentPay(address account,uint256 amount) external onlyManager {
        require(account != address(0));
        require(amount>0);
        
        IERC20(cfnxAddress).transferFrom(account,address(this),amount);
        uint256 idx = lockedIndexs[account].totalIdx;
        uint256 divAmount = (amount/dispatchTimes);

        lockedAllRewards[account][idx] = lockedReward(now,amount);
        
        //index 0 to save the left token num
        lockedAllRewards[account][idx].alloc[0] = amount.sub(divAmount);
        uint256 i=1;
        //idx = 0, the reward give user immediately
        for(;i<dispatchTimes-1;i++){
            lockedAllRewards[account][idx].alloc[i] = divAmount;
        }
        lockedAllRewards[account][idx].alloc[i] = amount.sub(divAmount.mul(dispatchTimes-1));
        
        
        lockedBalances[account] = lockedBalances[account].add(amount.sub(divAmount));
        
        //should can not be overflow
        lockedIndexs[account].totalIdx =  lockedIndexs[account].totalIdx + 1;
        
        IERC20(cfnxAddress).transfer(account,divAmount);
        
    }
    
    
    function claimFnxExpiredReward() public {
        uint256 txcnt = 0;
        uint256 i = lockedIndexs[tx.origin].beginIdx;
        uint256 endIdx = lockedIndexs[tx.origin].totalIdx;
        uint256 totalRet = 0;
        
        for(;i<endIdx && txcnt<txNum;i++) {

            if (now >= lockedAllRewards[tx.origin][i].startTime + lockPeriod) {
                totalRet = totalRet.add(lockedAllRewards[tx.origin][i].alloc[0]);
                lockedAllRewards[tx.origin][i].alloc[0] = 0;
                
                //updated last expired idx
                lockedIndexs[tx.origin].beginIdx = i;
            } else {
                uint256 timeIdx = (now - lockedAllRewards[tx.origin][i].startTime)/timeSpan;
                uint256 j = 1;
                uint256 subtotal = 0;
                for(;j>0&&j<timeIdx+1;j++) {
                    subtotal = subtotal.add(lockedAllRewards[tx.origin][i].alloc[j]);
                    lockedAllRewards[tx.origin][i].alloc[j] = 0;
                }
                
                //updated left locked balance
                lockedAllRewards[tx.origin][i].alloc[0] = lockedAllRewards[tx.origin][i].alloc[0].sub(subtotal);
                totalRet = totalRet.add(subtotal);
            }
            
            txcnt = txcnt + 1;
        }
        
        lockedBalances[tx.origin] = lockedBalances[tx.origin].sub(totalRet);
    }
    
}