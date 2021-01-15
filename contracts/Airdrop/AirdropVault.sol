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
        require(minBalForFreeClaim>0,"the thredhold for free claimer should be set");
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
    
    function update() onlyOwner public{ }
    
    function initAirdrop( address _optionColPool,
                                address _minePool,
                                address _fnxToken,
                                address _ftpbToken,
                                uint256 _claimBeginTime,
                                uint256 _claimEndTime,
                                uint256 _fnxPerFreeClaimUser,
                                uint256 _minBalForFreeClaim,
                                uint256 _maxFreeFnxAirDrop,
                                uint256 _maxWhiteListFnxAirDrop) public onlyOwner {
        optionColPool = _optionColPool;
        minePool = _minePool;
        fnxToken = _fnxToken;  
        ftpbToken = _ftpbToken;
        claimBeginTime = _claimBeginTime;
        claimEndTime = _claimEndTime;
        fnxPerFreeClaimUser = _fnxPerFreeClaimUser;
        minBalForFreeClaim = _minBalForFreeClaim;
        maxFreeFnxAirDrop = _maxFreeFnxAirDrop;
        maxWhiteListFnxAirDrop = _maxWhiteListFnxAirDrop;
    }
    
    function initSushiMine(address _cfnxToken,uint256 _sushiMineStartTime,uint256 _sushimineInterval) public onlyOwner{
        cfnxToken = _cfnxToken;
        sushiMineStartTime = _sushiMineStartTime;
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
    function balanceOfWhitListUser(address _account) public view returns (uint256) {
        return userWhiteList[_account];
    }


    function setWhiteList(address[] memory _accounts,uint256[] memory _fnxnumbers) public onlyOperator(1) {
        require(_accounts.length==_fnxnumbers.length,"the input array length is not equal");
        uint256 i = 0;
        for(;i<_accounts.length;i++) {
            userWhiteList[_accounts[i]] = _fnxnumbers[i];
            totalWhiteListAirdrop = totalWhiteListAirdrop.add(_fnxnumbers[i]);
            emit AddWhiteList(_accounts[i],_fnxnumbers[i]);
        }
    }
    
    
    function whitelistClaim() public airdropinited {
        require(userWhiteList[msg.sender]>0,"user balance is not enough");
        require(now >= claimBeginTime,"claim not begin");
        require(now < claimEndTime,"claim finished");
        
        uint256 amount = userWhiteList[msg.sender];
        userWhiteList[msg.sender] = 0;
        totalWhiteListClaimed = totalWhiteListClaimed.add(amount);
        require(totalWhiteListClaimed<=maxWhiteListFnxAirDrop,"total claim amount over max whitelist airdrop");
        
        IERC20(fnxToken).approve(optionColPool,amount);
        uint256 prefptb = IERC20(ftpbToken).balanceOf(address(this));
        IOptionMgrPoxy(optionColPool).addCollateral(fnxToken,amount);
        uint256 afterftpb = IERC20(ftpbToken).balanceOf(address(this));
        uint256 ftpbnum = afterftpb.sub(prefptb);
        IERC20(ftpbToken).approve(minePool,ftpbnum);
        
        IMinePool(minePool).lockAirDrop(msg.sender,ftpbnum);

        emit WhiteListClaim(msg.sender,amount,ftpbnum);
    }
    
    function setTokenList(address[] memory _tokens,bool[] memory _active) public onlyOperator(1) {
        uint256 i = 0;
        for(i=0;i<_tokens.length;i++) {
            require(tokenWhiteList[_tokens[i]]!=_active[i],"token already set");
            tokenWhiteList[_tokens[i]] = _active[i];
        }
    }

    function freeClaim(address _targetToken) public airdropinited {
        require(tokenWhiteList[_targetToken],"the target token is in token whitelist");
        require(now >= claimBeginTime,"claim not begin");
        require(now < claimEndTime,"claim finished");
        require(!freeClaimedUserList[msg.sender],"user claimed airdrop already");
  
        
        uint256 bal = ITargetToken(_targetToken).balanceOf(msg.sender);
        require(bal>minBalForFreeClaim,"user balance in target token is not reach minum require");
        
        totalFreeClaimed = totalFreeClaimed.add(fnxPerFreeClaimUser);
        require(totalFreeClaimed<=maxFreeFnxAirDrop,"total claim amount over max whitelist airdrop");
        
        IERC20(fnxToken).approve(optionColPool,fnxPerFreeClaimUser);
        
        uint256 prefptb = IERC20(ftpbToken).balanceOf(address(this));
        IOptionMgrPoxy(optionColPool).addCollateral(fnxToken,fnxPerFreeClaimUser);
        uint256 afterftpb = IERC20(ftpbToken).balanceOf(address(this));
        uint256 ftpbnum = afterftpb.sub(prefptb);
        
        IERC20(ftpbToken).approve(minePool,ftpbnum);
        IMinePool(minePool).lockAirDrop(msg.sender,ftpbnum);

        emit UserFreeClaim(msg.sender,fnxPerFreeClaimUser,ftpbnum);
    }   
    
   
   function setSushiMineList(address[] memory _accounts,uint256[] memory _fnxnumbers) public onlyOperator(1) {
        require(_accounts.length==_fnxnumbers.length,"the input array length is not equal");
        uint256 i = 0;
        uint256 idx = (now - sushiMineStartTime)/sushimineInterval;
        for(;i<_accounts.length;i++) {
            require((!sushiMineRecord[idx][msg.sender]),"user's mine have been set already");
            sushiMineRecord[idx][msg.sender] = true;
            
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
      
}
