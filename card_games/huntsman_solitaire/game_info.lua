--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-03-25 17:12:47",revision=1449]]

function game_info()
	return {
		sprite = --[[pod,pod_type="image"]]unpod("b64:bHo0AN4DAABkBQAA8QxweHUAQyAxTgQPHfYfDgb3HxYHDxAMBwwNBw0GAPMHLQwHPQcMHRcNDBcMDRctFy0MFxYHHQIA9gA9DD0MPQcdFx0HTQc9DAcZABJNBABQHB0HHQwKAAYaAAQCAEMNDAddCwAeHR8AHzccAAdTPRcdDC0MAAAeAABrAAQCAACNAE8HDB0HHgACMycMHasAD1cAAD83DA0dAAZhDQw3DxwMHwAAzgAOIQBCDAtHCx8AGAcfACE9DEQBfQsHCycMNxwfAMEMHQwLBxtnCw0LZwtrARYdHQD3ABcMG1cMCycMDQwnCwxXCxsAQA0MVws6AFInDC0MJwoABD4AERaLAPMBNwwtDBsnDE0MJxs9DDcLDBkAQAsnDD0dABBtFABBPQwnCxgAAGAAYC0MC1cMjVcAEC1yAPAEBxYHDAsXDB0MdwytDHcMHQwXC9oBABMAAMgAcAzNDDcMJwsXAPAwBxYnDB0LFwxHDO0MRwwXCx0MJxYXCx0LRw0XDE0XDxcNChdNDBcNRwsdCxcWBwsdDDcNN30HDQd9Nw03DB0LaQDyAB0nDCcNBwwdCgcdCgcKDQQAgC0MBw0nDCcddwCiDA0MBwsnDSc9B5wBUT0nDScLFgBBFgcdCz4AsT0HHQoXDRcKHQc9OAARC-EAAXYBYCc9B60HPRQAEgcWACM3C28AYAqNCgcKHWkAIQs3GgCxVws3fQwNDH03C1cQANF3CxcLbQwNDG0LFwt3EgDRtwscLQwLDQsMLRwLtxIAUvcDLfcDCgBiAgwtDPcCDABhAAxtDPcADABSxwzNDMcWABEZBwBhRwz9DQxHCwBSNwz9Dwx9AHQ3HQz3CwwdDQBQFx0MBwz9ASIHDQIAAHwDJgwXIAABFQAQJwYAIS0nJQAZNzwAQA0nDQwfAAVAAAQ7AHEMJx0XDSctFQAGXwABXAAAHgPwCBYHDG33DW0MBxYXDF0XDw4XDB0HLQcd_wLyAAwdFwkXXQwXFmcdBwkICWMAJgcNQgABFgBAHWcWZykAIgwdGQAAxAFRHQwXCRcZAAHkADBnFmf4ADBnFncKAeB3FvcfFkcs9w8MDQxHFrsC8A53CQgJZxkHGVcMLQw3FiccLRxXCSgJRwkYCRgJN9YCIBYXxAJzCUgJN2g3bQ4AEWgQAAEOADEtDC0eABBHNgAwDB0MlQLZRwwNDHcJKAlnCQgJd2oAMYcJd2gA9Cv3Hxb3HwYO9h8ODw3_HxX_HxUOBf4bBQ4VHgX_GQUeFS4PBf4XBC4VPgT_FQQ_FU70FU4VTgT1EwROEwAhLgQhAAMwAAM_AHD_HwUE9R8E"),
		name = "Huntsman Solitaire",
		author = "Louie Chapman",
		description = "Hunt down the four matching ranked cards to win!",
		rules = {
			"\tCards are stacked with either decreasing or matching values. However, a stack can only be moved when following either rule, and not both.",
			"\tAces can be placed on any card, and any card can be placed on Aces.",
			"\tWhen clicked, the draw pile on the right will deal a card to every column.",
			"\tThe reserve deck on the left contains cards that can be played onto any valid position, but cards can not be played onto the reserve deck.",
			"\tCards can be stacked on both the draw deck, and/or reserve deck, when they have no cards remaining.",
			"\tTo win, match four-of-a-kind on each of the cards on the top of the tableau.",
			},
		api_version = 1,
		order = 1
	}
end
