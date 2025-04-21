// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // keeps track of the amount of tokens available in this contract (liquidity pool)
    uint public reserve0;
    uint public reserve1;

    // total shares
    uint public totalSupply;
    // shares for each user
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
      balanceOf[_to] += _amount;
      totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
      balanceOf[_from] -= _amount;
      totalSupply -= _amount;
    }

    function _updateReserves(uint _reserve0, uint _reserve1) private {
      reserve0 = _reserve0;
      reserve1 = _reserve1;
    }

    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut) {
      // validation
      require(
        _tokenIn == address(token0) || _tokenIn == address(token1),
        "invalid token"
      );

      require(_amountIn > 0, "amount in must be greater than 0");

      // determine tokenIn and tokenOut for this swap.
      bool isToken0 = _tokenIn == address(token0);
      (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0 
        ? (token0, token1, reserve0, reserve1)
        : (token1, token0, reserve1, reserve0);

      // this is the token the user is selling in this swap (going in)
      tokenIn.transferFrom(msg.sender, address(this), _amountIn);

      // calculate the fees (it is 0.3%)
      uint amountOutWithFee = (_amountIn * 997) * 1000; // 997/1000 = 99.7 % 

      // calculate the amount token out
      // amountOfTokenOut = (amountOfToken1 * amountInOfToken0) divided by (amountOfToken0 + amountOfToken0)
      // dy = ydx / (x + dx)
      amountOut = (reserveOut * amountOutWithFee) / (reserveIn + amountOutWithFee);

      // transfer tokenOut to user
      // this is the token the user is buying in this swap (going out)
      tokenOut.transfer(msg.sender, amountOutWithFee);

      // update the reserves after swap
      _updateReserves(token0.balanceOf(address(this)),token1.balanceOf(address(this)));
    }

    function addLiquidity(uint _amountA, uint _amountB) external {
      
    }

    function removeLiquidity() external {}

}
