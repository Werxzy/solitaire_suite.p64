--[[pod_format="raw",created="2024-03-25 02:14:11",modified="2024-03-25 03:04:26",revision=109]]

function game_info()
	return {
		sprite = --[[pod,pod_type="image"]]unpod("b64:bHo0AOECAADTBwAA8BxweHUAQyAxTgQPHfYfDgb3Hxb3HxYnDw74Fw0nFhcN_BkNFxYXGA33FQ0YCQA-Fw0HAgAOERcqAE8HDQcIAgAOIg0HVgBECPcRCDcAZScI9wAI1xoA8QIHKAcYDRcYBxgNBw0YBw0IDQQANxgNBzEAPxcIBwIABhUXSgC1Fw0XCCcNGAcoByhIACUIJ0cAQtcI9wQsABodUAA9JwgHAgABNQA-HQcNAgAS8gYYFxb3Gx0XFhcNKA1nCA1HCA33BB11APATCGcYRxgXDQgHCA33ARYXGDcNKA0HGAcYBzgHSAcYBw0YDTUAAjsA8AAHGB0IBxg3DRgNB0g3GAcGAYAHDQgXFkcYBygBABIAIRcYKQAhCA0SAEFIFxYXJgABOQBxBxgXGCcNCEwBMjcYR1MAAy4AgQgNFwgNNw0nCwAAhAAQFwcCLhcd7wEANgAGFgAvFx0HAQZWGA0nDQcCABMdPgILAAI1FzgNFQAPOQIHAs8AGQ0QAA9PAAM-GB0IUAASAfwAD1AADx_HTAASAL4BD04AET8XSBdQABEfSEwAEgKIAQ9OAA42Fw0IKAAPUAAIPzcNN04AEB5nmgAP0wEnLw0nTgA3PzcYB00AEC9HGB0CiAChAw9SABE-GA0YUAASLw04OQE4Pw0IFx8CKCIPGhUAD7oCDDQsCAcCAD8NJw2ZAARCHA8bHBUAD_UABoMNHAsDCxwNBwIAAksABgIAA0sARCwDCxMlAAGaAwMCAAJHAOENFwwLHAMcAwyHDSgNt-0G8QENKAwLAwtMaB1nHagNFxYnQgAzLHgd5AFyHZgNJxYnHDYAILdIzwX0QxwLDAtMx0j3AQYOFg8LEwsDCyr2FA4PDR47Ayv_FRk_GwMb-hYZDgkuK-4VCQ4ZHgkuC-4VCR4ZLg8S-hcFLhk_Bf4VBT4ZTvUVThlOBfkTBU4TACEuBSEA8AYeCf4ZCR4ZDgn_GwkOGf4fCQX5HwU="),
		name = "Trapdoor Solitaire",
		author = "Louie Chapman",
		description = "A spider solitaire variant with Aces acting as wild, but a more restrictive tableau",
		rules = {
			"\tCards can only be stacked in descending values with matching suits",
			"\tWithin a suit, Aces can be placed on any card, and any card can be placed on an Ace. (1 does not count as an Ace)",
			"\tWhen part of a larger stack, Aces are counted as if they were not there, and Stacks can be moved even with Aces within them.",
			"\tTo win, create an ordered stack for each of the 4 suits ranging from 9 to 1",
		}
	}
end
