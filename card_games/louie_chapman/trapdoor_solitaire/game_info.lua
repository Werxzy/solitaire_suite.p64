--[[pod_format="raw",created="2024-03-25 02:14:11",modified="2024-03-26 21:14:05",revision=131]]

function game_info()
	return {
		sprite = 
--[[pod,pod_type="image"]]unpod("b64:bHo0AMwCAADIBwAA8BxweHUAQyAxTgQPHfYfDgb3Hxb3HxYnDw74Fw0nFhcN_BkNFxYXGA33FQ0YCQA-Fw0HAgAOERcqAE8HDQcIAgAOIg0HVgBECPcRCDcAZScI9wAI1xoA8QIHKAcYDRcYBxgNBw0YBw0IDQQANxgNBzEAPxcIBwIABhUXSgC1Fw0XCCcNGAcoByhIADYIJwivAEK3CPcELgAaHVIAPScIBwIAATcAPx0HDQIAEvAFGBcW9xsdFxYXDSgNZwgNRwgN9wQPAPATGJcYRxgXDQgHCA33ARYXGDcNKA0HGAcYBzgHSAcYBw0YDTIAAjgA8AAHGB0IBxg3DRgNB0g3GAcFAYAHDQgXFkcYBycBABIAIRcYKQAhCA0SABJIHAAANgBxBxgXGCcNCEgBMjcYR1AAAysAgQgNFwgNNw0nCwAAgQAQFwMCLhcd6wEANgAGFgAvFx0BAQZGGDcNBwIAEx05Agv7ATUXOA0VAA80AgcCDwEYDRAAD08ABADlAA9QABEB_wAPUAAPH4dMABIAugEPTgARPxdIF1AAER9ITAASAocBD04ADjYXDQgoAA9QAAg-Nw03TgAQH2eaADgBIQIPTgAPLxhH0AE4AGgDD04ADz83GAfoADgPNAETAEQCD04AEQ8KAz8fODkBOC8NCE0ABU8PGggHVwMMPywIB9EBEEIcDxscFQAPUgMFgw0cCwMLHA0HAgABzgEGAgADSQBSLAMLExzIBDcXDTjRBAEgANENFwwLHAMcAwy3GMcYegVjDAsDC0x4mABRuA0XFidDALMsiA1nDagNJxYnHDEABcgF_EAcCwwLTMdI9wEGDgYHCx8TCwMLKv8NDA4WNwYOCR8SMwoDJvcJNg4JRRkFCQ4KGwMLCv4UCQUZBS4DKwP_FQUZBT4DCwP_FjlOA-4XOf4dAwCgKQX_HQUZBQn_GzEAoAn_GwkFCQX5HwU=")
		,
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
