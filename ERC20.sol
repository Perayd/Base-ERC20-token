// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin imports (install @openzeppelin/contracts)
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol"; // permit (EIP-2612)
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ExampleToken - configurable ERC20 base token for EVM chains
/// @notice Owner can mint, pause, take snapshots, and change configuration via code
contract ExampleToken is ERC20, ERC20Burnable, ERC20Snapshot, ERC20Permit, Pausable, Ownable {
    /// @param name_ token name (e.g. "Example Token")
    /// @param symbol_ token symbol (e.g. "EXM")
    /// @param initialSupply initial supply minted to deployer (in wei-style, include decimals)
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply);
        }
    }

    // ----- Owner-only management -----

    /// @notice Mint tokens to `to`. Only owner.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @notice Create an on-chain snapshot (useful for airdrops, governance, etc). Only owner.
    function snapshot() external onlyOwner returns (uint256) {
        return _snapshot();
    }

    /// @notice Pause transfers. Only owner.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause transfers. Only owner.
    function unpause() external onlyOwner {
        _unpause();
    }

    // ----- Overrides required by multiple inheritance -----

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);

        // block transfers while paused (but allow mint/burn when from==address(0) or to==address(0) if you want)
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

    // If you add voting or other extensions, you may need other overrides here.
}
