// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Carbon is ERC20, Ownable {
    uint256 public transferFee = 0; // 10 basis points (0.1%)

    uint256 private _totalMinted;

    constructor() ERC20("Carbon", "CARB") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
        _totalMinted += amount;
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function setTransferFee(uint256 fee) public onlyOwner {
        require(fee <= 1000, "Fee cannot exceed 10%");
        transferFee = fee;
    }

    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        uint256 feeAmount = (amount * transferFee) / 10000;
        uint256 netAmount = amount - feeAmount;

        _transfer(_msgSender(), to, netAmount);
        if (feeAmount > 0) {
            _burn(_msgSender(), feeAmount);
        }

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 feeAmount = (amount * transferFee) / 10000;
        uint256 netAmount = amount - feeAmount;

        _transfer(sender, recipient, netAmount);
        if (feeAmount > 0) {
            _burn(sender, feeAmount);
        }

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
}
