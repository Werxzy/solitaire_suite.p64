--[[pod_format="raw",created="2024-03-25 02:12:03",modified="2024-03-26 21:14:08",revision=1541]]

function game_info()
	return {
		sprite = 
--[[pod,pod_type="image"]]unpod("b64:bHo0AEkEAAAsBgAA8QxweHUAQyAxTgQPHfYfDgb3HxYHDxAMBwwNBw0GAPMHLQwHPQcMHRcNDBcMDRctFy0MFxYHHQIA9gA9DD0MPQcdFx0HTQc9DAcZABJNBABQHB0HHQwKAAYaAAQCAEMNDAddCwAeHR8AHzccAAdTPRcdDC0MAAAeAABrAAQCAACNAE8HDB0HHgACMycMHasAD1cAAD83DA0dAAZhDQw3DxwMHwAAzgAOIQBCDAtHCx8AGAcfACE9DEQBfQsHCycMNxwfAMEMHQwLBxtnCw0LZwtrARYdHQD3ABcMG1cMCycMDQwnCwxXCxsAQA0MVws6AFInDC0MJwoABD4AERaLAPMBNwwtDBsnDE0MJxs9DDcLDBkAQAsnDD0dABBtFABBPQwnCxgAAGAAYC0MC1cMjVcAEC1yAPAEBxYHDAsXDB0MdwytDHcMHQwXC9oBABMAAMgAcAzNDDcMJwsXAPAwBxYnDB0LFwxHDO0MRwwXCx0MJxYXCx0LRw0XDE0XDxcNChdNDBcNRwsdCxcWBwsdDDcNN30HDQd9Nw03DB0LaQDyAB0nDCcNBwwdCgcdCgcKDQQAgC0MBw0nDCcddwCiDA0MBwsnDSc9B5wBUT0nDScLFgBBFgcdCz4AsT0HHQoXDRcKHQc9OAARC-EAAXYBYCc9B60HPRQAEgcWACM3C28AYAqNCgcKHWkAIQs3GgCxVws3fQwNDH03C1cQANF3CxcLbQwNDG0LFwt3EgDRtwscLQwLDQsMLRwLtxIAUvcDLfcDCgBiAgwtDPcCDABhAAxtDPcADABSxwzNDMcWABEZBwBhRwz9DQxHCwBSNwz9Dwx9AHQ3HQz3CwwdDQBQFx0MBwz9ASIHDQIAAHwDJgwXIAABFQAQJwYAIS0nJQAZNzwAQA0nDQwfAAVAAAQ7AHEMJx0XDSctFQAGXwABXAAAHgPwARYHDC0MCx33DR0LDC0MBxYGAsALHRcPDhcMHQctBx0EA2AMHRcJFx15AoIXFmcdBwkICW8AJgcNTgABFgBAHWcWZywAIgwdGQAA0AEgHQw9AAAZAAHwADBnFmcEATBnFncWAeB3FvcfFkcs9w8MDQxHFscC8A53CQgJZxkHGVcMLQw3FiccLRxXCSgJRwkYCRgJN_ICIBYX0AJzCUgJN2g3bQ4AEWgQAAEOADEtDC0eABBHNgAwDB0MoQLZRwwNDHcJKAlnCQgJd2oAMYcJd2gA8SL3Hxb3HwYOBjcWDv8NDw4WNwYOBU8SBQ429wk2DgVEFQQF-hsFBBUE3gEOEQ4BDgENAwDzCw4NAd4EFQQeBZT_A5QFHjUOBaQODQEEAQQRBADzAwENDqQFDjUOFAWeAQ8FDgMOEwQAUAMBngUUGQBpHkUkDgEDGgBPDiRFHhwADk8FngEDUAAALQWkMgBApAUOJaMADRkAi5QFHgQVBAXOsgAQzugAoAX_GwUEBQT1HwQ=")
		,
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
		order = 4
	}
end
