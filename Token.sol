// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaLandPlay is ERC20, Ownable {
    address public feeAddress;

    bool public feesActivated;

    uint internal _fee;        

    mapping(address => bool) internal _excludeFromFee;
    mapping(address => bool) internal _blacklist;

    constructor(address _feeAddress) ERC20("Meta Land Play", "MLAND") {
        feeAddress = _feeAddress;
        _mint(msg.sender, 30000000 ether); // 30.000.000

        // Fees
        _fee = 25;
        feesActivated = false;
    }

    // Include & Exlcude from fees
    function excludeFromFee(address _address) public onlyOwner{
        _excludeFromFee[_address] = true;
    }
    function includeFromFee(address _address) public onlyOwner{
        _excludeFromFee[_address] = false;
    }
    function isExcludedFromFee(address _address) public view returns(bool) {
        return _excludeFromFee[_address];
    }

    // Mofidy Fees
    function modifyFee(uint _newFee) public onlyOwner{
        _fee = _newFee;
    }
    function mofidyFeeAddress(address _newFeeAddress) public onlyOwner {
        feeAddress = _newFeeAddress;
    }
    function pauseFees() public onlyOwner{
        feesActivated = false;
    }
    function unpauseFees() public onlyOwner{
        feesActivated = true;
    }
    

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_blacklist[msg.sender] == false, "You are blacklisted");

        if(_excludeFromFee[msg.sender] == true){
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        if(feesActivated){
            uint _feeAmount = amount / _fee;
            _transfer(_msgSender(), feeAddress, _feeAmount); // fees
            _transfer(_msgSender(), recipient, amount - _feeAmount); // result amount
            return true;
        }
    
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function seeFees() public view returns(uint){
        return _fee;
    }
}
