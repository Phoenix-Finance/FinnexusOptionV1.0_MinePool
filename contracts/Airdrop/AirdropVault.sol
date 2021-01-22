pragma solidity =0.5.16;
import "./AirdropVaultData.sol";
import "../modules/SafeMath.sol";
import "../ERC20/IERC20.sol";


interface IOptionMgrPoxy {
    function addCollateral(address collateral,uint256 amount) external payable;
}

interface IMinePool {
    function lockAirDrop(address user,uint256 ftp_b_amount) external;
}

interface ITargetToken {
     function balanceOf(address account) external view returns (uint256);
}


contract AirDropVault is AirDropVaultData {
    using SafeMath for uint256;
    
    modifier airdropinited() {
        require(optionColPool!=address(0),"collateral pool address should be set");
        require(minePool!=address(0),"mine pool address should be set");
        require(fnxToken!=address(0),"fnx token address should be set");
        require(ftpbToken!=address(0),"ftpb token address should be set");
        require(claimBeginTime>0,"airdrop claim begin time should be set");
        require(claimEndTime>0,"airdrop claim end time should be set");
        require(fnxPerFreeClaimUser>0,"the air drop number for each free claimer should be set");
        require(maxWhiteListFnxAirDrop>0,"the max fnx number for whitelist air drop should be set");
        require(maxFreeFnxAirDrop>0,"the max fnx number for free air drop should be set");
        _;
    }
    
    modifier suhsimineinited() {
        require(cfnxToken!=address(0),"cfnc token address should be set");
        require(sushiMineStartTime>0,"sushi mine start time should be set");
        require(sushimineInterval>0,"sushi mine interval should be set");
        _;
    }    

    function initialize() onlyOwner public {}
    
    function update() onlyOwner public{ 
        totalFreeClaimed = 0;
    }
    
    function initAirdrop( address _optionColPool,
                                address _minePool,
                                address _fnxToken,
                                address _ftpbToken,
                                uint256 _claimBeginTime,
                                uint256 _claimEndTime,
                                uint256 _fnxPerFreeClaimUser,
                                uint256 _maxFreeFnxAirDrop,
                                uint256 _maxWhiteListFnxAirDrop) public onlyOwner {
        if(_optionColPool!=address(0))                            
            optionColPool = _optionColPool;
        if(_minePool!=address(0))    
            minePool = _minePool;
        if(_fnxToken!=address(0))    
            fnxToken = _fnxToken;  
        if(_ftpbToken!=address(0))    
            ftpbToken = _ftpbToken;
        
        if(_claimBeginTime>0)    
            claimBeginTime = _claimBeginTime;
         
        if(_claimEndTime>0)    
            claimEndTime = _claimEndTime;
            
        if(_fnxPerFreeClaimUser>0)    
            fnxPerFreeClaimUser = _fnxPerFreeClaimUser;

        if(_maxFreeFnxAirDrop>0)
            maxFreeFnxAirDrop = _maxFreeFnxAirDrop;
            
        if(_maxWhiteListFnxAirDrop>0)    
            maxWhiteListFnxAirDrop = _maxWhiteListFnxAirDrop;
    }
    
    function initSushiMine(address _cfnxToken,uint256 _sushiMineStartTime,uint256 _sushimineInterval) public onlyOwner{
        if(_cfnxToken!=address(0))
            cfnxToken = _cfnxToken;
        if(_sushiMineStartTime>0)    
            sushiMineStartTime = _sushiMineStartTime;
        if(_sushimineInterval>0)    
            sushimineInterval = _sushimineInterval;
    }
    

    /**
     * @dev getting back the left mine token
     * @param _reciever the reciever for getting back mine token
     */
    function getbackLeftFnx(address _reciever)  public onlyOwner {
        uint256 bal =  IERC20(fnxToken).balanceOf(address(this));
        IERC20(fnxToken).transfer(_reciever,bal);
    }  

    /**
     * @dev Retrieve user's locked balance. 
     * @param _account user's account.
     */ 
    function balanceOfWhitListUser(address _account) private view returns (uint256) {
        uint256 amount = userWhiteList[_account];
        uint256 total = totalWhiteListClaimed.add(amount);
        if (total>maxWhiteListFnxAirDrop){
            amount = maxWhiteListFnxAirDrop.sub(totalWhiteListClaimed);
        }
        return amount;
    }


    function setWhiteList(address[] memory _accounts,uint256[] memory _fnxnumbers) public onlyOperator(1) {
        require(_accounts.length==_fnxnumbers.length,"the input array length is not equal");
        uint256 i = 0;
        for(;i<_accounts.length;i++) {
            if(userWhiteList[_accounts[i]]==0) {
               totalWhiteListAirdrop = totalWhiteListAirdrop.add(_fnxnumbers[i]);
               userWhiteList[_accounts[i]] = _fnxnumbers[i];
               emit AddWhiteList(_accounts[i],_fnxnumbers[i]);
            }
        }
    }
    
    
    function whitelistClaim() public airdropinited {
       
        require(now >= claimBeginTime,"claim not begin");
        require(now < claimEndTime,"claim finished");
        
         if(userWhiteList[msg.sender]>0) {
        
            uint256 amount = userWhiteList[msg.sender];
            userWhiteList[msg.sender] = 0;
            if(totalWhiteListClaimed>maxWhiteListFnxAirDrop) {
                return;
            } else {
                uint256 total = totalWhiteListClaimed.add(amount);
                if (total>maxWhiteListFnxAirDrop){
                    amount = maxWhiteListFnxAirDrop.sub(totalWhiteListClaimed);
                }
                totalWhiteListClaimed = totalWhiteListClaimed.add(amount);
                
                IERC20(fnxToken).approve(optionColPool,amount);
                uint256 prefptb = IERC20(ftpbToken).balanceOf(address(this));
                IOptionMgrPoxy(optionColPool).addCollateral(fnxToken,amount);
                uint256 afterftpb = IERC20(ftpbToken).balanceOf(address(this));
                uint256 ftpbnum = afterftpb.sub(prefptb);
                IERC20(ftpbToken).approve(minePool,ftpbnum);
                
                IMinePool(minePool).lockAirDrop(msg.sender,ftpbnum);
        
                emit WhiteListClaim(msg.sender,amount,ftpbnum);
            }
         }
    }
    
    function setTokenList(address[] memory _tokens,uint256[] memory _minBalForFreeClaim) public onlyOwner {
        uint256 i = 0;
        require(_tokens.length==_minBalForFreeClaim.length,"array length is not match");
        for (i=0;i<_tokens.length;i++) {
            require(_minBalForFreeClaim[i]>0);
            if(tkBalanceRequire[_tokens[i]]==0) {
                tkBalanceRequire[_tokens[i]] = _minBalForFreeClaim[i];
                tokenWhiteList.push(_tokens[i]);
            }
        }
    }
    
    function balanceOfFreeClaimAirDrop(address _targetToken,address _account) public view airdropinited returns(uint256){
        require(tkBalanceRequire[_targetToken]>0,"the target token is not set active");
        require(now >= claimBeginTime,"claim not begin");
        require(now < claimEndTime,"claim finished");
        if(totalFreeClaimed < maxFreeFnxAirDrop) {
            if(!freeClaimedUserList[_targetToken][_account]) {
                uint256 bal = ITargetToken(_targetToken).balanceOf(_account);
                if(bal>=tkBalanceRequire[_targetToken]) {
                    uint256 amount = fnxPerFreeClaimUser;
                    uint256 total = totalFreeClaimed.add(amount);
                    if(total>maxFreeFnxAirDrop) {
                        amount = maxFreeFnxAirDrop.sub(totalFreeClaimed);
                    }
                    return amount;
                }
            }
        }

        return 0;
    }

    function freeClaim(address _targetToken) public airdropinited {
        require(tkBalanceRequire[_targetToken]>0,"the target token is not set active");
        require(now >= claimBeginTime,"claim not begin");
        require(now < claimEndTime,"claim finished");
        
        if(!freeClaimedUserList[_targetToken][msg.sender]) {
            //set user claimed already
            freeClaimedUserList[_targetToken][msg.sender] = true;
            
            uint256 bal = ITargetToken(_targetToken).balanceOf(msg.sender);
            if(bal>=tkBalanceRequire[_targetToken]){
                uint256 amount = fnxPerFreeClaimUser;
                
                if(totalFreeClaimed>maxFreeFnxAirDrop) {
                    return;
                } else {
                    uint256 total = totalFreeClaimed.add(amount);
                    if(total>maxFreeFnxAirDrop) {
                        amount = maxFreeFnxAirDrop.sub(totalFreeClaimed);
                    }
                    totalFreeClaimed = totalFreeClaimed.add(amount);
                    
                    IERC20(fnxToken).approve(optionColPool,amount);
                    
                    uint256 prefptb = IERC20(ftpbToken).balanceOf(address(this));
                    IOptionMgrPoxy(optionColPool).addCollateral(fnxToken,amount);
                    uint256 afterftpb = IERC20(ftpbToken).balanceOf(address(this));
                    uint256 ftpbnum = afterftpb.sub(prefptb);
                    
                    IERC20(ftpbToken).approve(minePool,ftpbnum);
                    IMinePool(minePool).lockAirDrop(msg.sender,ftpbnum);
                    
                    emit UserFreeClaim(msg.sender,amount,ftpbnum);
                }
            }
        }
    }   
    
   
   function setSushiMineList(address[] memory _accounts,uint256[] memory _fnxnumbers) public onlyOperator(1) {
        require(_accounts.length==_fnxnumbers.length,"the input array length is not equal");
        uint256 i = 0;
        uint256 idx = (now - sushiMineStartTime)/sushimineInterval;
        for(;i<_accounts.length;i++) {
            require((!sushiMineRecord[idx][_accounts[i]]),"user's mine have been set already");
            sushiMineRecord[idx][_accounts[i]] = true;
            
            suhiUserMineBalance[_accounts[i]] = suhiUserMineBalance[_accounts[i]].add(_fnxnumbers[i]);
            sushiTotalMine = sushiTotalMine.add(_fnxnumbers[i]);
            
            emit AddSushiList(_accounts[i],_fnxnumbers[i]);
        }
    }
    
    function sushiMineClaim() public suhsimineinited {
        require(suhiUserMineBalance[msg.sender]>0,"sushi mine balance is not enough");
        
        uint256 amount = suhiUserMineBalance[msg.sender];
        suhiUserMineBalance[msg.sender] = 0;
        
        uint256 precfnx = IERC20(cfnxToken).balanceOf(address(this));
        IERC20(cfnxToken).transfer(msg.sender,amount);
        uint256 aftercfnc = IERC20(cfnxToken).balanceOf(address(this));
        uint256 cfncnum = precfnx.sub(aftercfnc);
        require(cfncnum==amount,"transfer balance is wrong");
        emit SushiMineClaim(msg.sender,amount);
    }
    
    function balanceOfAirDrop(address _account) public view returns(uint256){
        uint256 whitelsBal = balanceOfWhitListUser(_account);
        uint256 i = 0;
        uint256 freeClaimBal = 0;
        for(i=0;i<tokenWhiteList.length;i++) {
           freeClaimBal = freeClaimBal.add(balanceOfFreeClaimAirDrop(tokenWhiteList[i],_account));
        }
        
        return whitelsBal.add(freeClaimBal);
    }
    
    function claimAirdrop() public {
         whitelistClaim();
         uint256 i;
         for(i=0;i<tokenWhiteList.length;i++) {
            freeClaim(tokenWhiteList[i]);
         }
    }
      
}
