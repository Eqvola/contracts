// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./token/ERC20/ERC20.sol";
import "./Delegable.sol";

contract CoinDogsTestERC20 is ERC20, Delegable {
    // solhint-disable-next-line no-empty-blocks
    constructor() ERC20("TestCoinDogs", "TCDG") {
        
       // вписати сюди _mint(address(this), кількість токенів, яку треба випустити)
    }

    function mint(address to, uint256 amount) external onlyOwnerOrApproved {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwnerOrApproved {
        _burn(from, amount);
    }
    function transferApproved(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        require(isApproved(_msgSender()), "ERC20: transfer amount exceeds allowance");
        return true;
    }
}
