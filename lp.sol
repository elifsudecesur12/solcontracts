// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPool is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public totalLiquidity;

    mapping(address => uint256) public balances;

    event LiquidityProvided(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function provideLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer of tokenA failed");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer of tokenB failed");

        uint256 liquidity = (totalLiquidity == 0) ? amountA : (amountA * totalLiquidity) / totalReserveA();
        totalLiquidity += liquidity;
        balances[msg.sender] += liquidity;

        emit LiquidityProvided(msg.sender, amountA, amountB);
    }

    function removeLiquidity(uint256 liquidity) external {
        require(liquidity > 0 && balances[msg.sender] >= liquidity, "Invalid liquidity amount");
        uint256 amountA = (liquidity * totalReserveA()) / totalLiquidity;
        uint256 amountB = (liquidity * totalReserveB()) / totalLiquidity;

        totalLiquidity -= liquidity;
        balances[msg.sender] -= liquidity;

        require(tokenA.transfer(msg.sender, amountA), "Transfer of tokenA failed");
        require(tokenB.transfer(msg.sender, amountB), "Transfer of tokenB failed");

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    function totalReserveA() public view returns (uint256) {
        return tokenA.balanceOf(address(this));
    }

    function totalReserveB() public view returns (uint256) {
        return tokenB.balanceOf(address(this));
    }
}
