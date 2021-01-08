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

contract AirDropVault is AirDropVaultData {
    using SafeMath for uint256;
    

    function initialize() onlyOwner public {
    }
    
    function update() onlyOwner public{
    }
    
    function setOptionColPool(address _optionColPool) public onlyOwner {
        optionColPool = _optionColPool;
    }
    
    function setMinePool( address _minePool) public onlyOwner {
        minePool = _minePool;
    }
    
    function setFnxToken(address _fnxToken) public onlyOwner {
        fnxToken = _fnxToken;
    }
   
    function setFptbToken(address _ftpbToken) public onlyOwner {
        ftpbToken = _ftpbToken;
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
    function balanceOfAirdrop(address _account) public view returns (uint256) {
        return airDropWhiteList[_account];
    }


    function addWhiteList(address _account,uint256 _fnxnumber) public onlyOperator() {
        airDropWhiteList[_account] = _fnxnumber;
    }
    
    
    function claim() external {
        require(optionColPool!=address(0),"collateral pool address should be set");
        require(minePool!=address(0),"mine pool address should be set");
        require(fnxToken!=address(0),"fnx token address should be set");
        require(ftpbToken!=address(0),"ftpb token address should be set");
        require(airDropWhiteList[tx.origin]>0,"claimer should be in whitelist");

        uint256 amount = airDropWhiteList[tx.origin];
        airDropWhiteList[tx.origin] = 0;
        IERC20(fnxToken).approve(optionColPool,amount);
        uint256 prefptb = IERC20(ftpbToken).balanceOf(address(this));
        IOptionMgrPoxy(optionColPool).addCollateral(fnxToken,amount);
        uint256 afterftpb = IERC20(ftpbToken).balanceOf(address(this));
        uint256 ftpbnum = afterftpb.sub(prefptb);
        IERC20(ftpbToken).approve(minePool,ftpbnum);
        IMinePool(minePool).lockAirDrop(tx.origin,ftpbnum);

        emit ClaimAirdrop(tx.origin,amount,ftpbnum);
    }
    
}
