-- Custom emoji completion source for blink.cmp
-- Provides emoji autocomplete with colon-prefix trigger (e.g., :blush: → 😊)
--
-- ## Adding New Emojis
--
-- 1. Find emoji in Unicode database:
--    grep -i "star-struck" /usr/share/unicode/emoji/emoji-test.txt
--    Output: 1F929  ; fully-qualified  # 🤩 E5.0 star-struck
--
-- 2. Get GitHub shortcode using hex code:
--    curl -s "https://api.github.com/emojis" | jq -r 'to_entries[] | select(.value | contains("1f929")) | .key'
--    Output: star_struck
--
-- 3. Verify the emoji:
--    printf '\U1F929\n'  # Outputs: 🤩
--
-- 4. Add to emojis table below:
--    { name = "star_struck", emoji = "🤩", description = "Star-struck" },
--
-- Note: Shortcodes follow GitHub's emoji API standard for compatibility.

local M = {}

-- Static emoji list with names and Unicode characters
-- Shortcodes match GitHub's emoji API: https://api.github.com/emojis
local emojis = {
	-- Faces
	{ name = "blush", emoji = "😊", description = "Smiling face" },
	{ name = "grin", emoji = "😁", description = "Beaming face with smiling eyes" },
	{ name = "joy", emoji = "😂", description = "Face with tears of joy" },
	{ name = "sweat_smile", emoji = "😅", description = "Grinning face with sweat" },
	{ name = "star_struck", emoji = "🤩", description = "Star-struck" },
	{ name = "thinking", emoji = "🤔", description = "Thinking face" },
	{ name = "fearful", emoji = "😨", description = "Fearful face" },

	-- Hands & gestures
	{ name = "thumbsup", emoji = "👍", description = "Thumbs up" },
	{ name = "+1", emoji = "👍", description = "Thumbs up (alias)" },
	{ name = "thumbsdown", emoji = "👎", description = "Thumbs down" },
	{ name = "-1", emoji = "👎", description = "Thumbs down (alias)" },
	{ name = "wave", emoji = "👋", description = "Waving hand" },
	{ name = "clap", emoji = "👏", description = "Clapping hands" },
	{ name = "pray", emoji = "🙏", description = "Folded hands" },

	-- Symbols & objects
	{ name = "heart", emoji = "❤️", description = "Red heart" },
	{ name = "fire", emoji = "🔥", description = "Fire" },
	{ name = "rocket", emoji = "🚀", description = "Rocket" },
	{ name = "star", emoji = "⭐", description = "Star" },
	{ name = "sparkles", emoji = "✨", description = "Sparkles" },
	{ name = "tada", emoji = "🎉", description = "Party popper" },
	{ name = "white_check_mark", emoji = "✅", description = "Check mark button" },
	{ name = "x", emoji = "❌", description = "Cross mark" },
	{ name = "warning", emoji = "⚠️", description = "Warning" },

	-- Dev & work
	{ name = "bug", emoji = "🐛", description = "Bug" },
	{ name = "wrench", emoji = "🔧", description = "Wrench" },
	{ name = "hammer", emoji = "🔨", description = "Hammer" },
	{ name = "pencil2", emoji = "✏️", description = "Pencil" },
	{ name = "pencil", emoji = "📝", description = "Memo" },
	{ name = "memo", emoji = "📝", description = "Memo" },
	{ name = "book", emoji = "📖", description = "Open book" },
	{ name = "open_book", emoji = "📖", description = "Open book" },
	{ name = "bulb", emoji = "💡", description = "Light bulb" },
	{ name = "computer", emoji = "💻", description = "Laptop" },
	{ name = "iphone", emoji = "📱", description = "Mobile phone" },
	{ name = "camera", emoji = "📷", description = "Camera" },

	-- Body parts & misc
	{ name = "eyes", emoji = "👀", description = "Eyes" },
	{ name = "brain", emoji = "🧠", description = "Brain" },
	{ name = "muscle", emoji = "💪", description = "Flexed biceps" },
	{ name = "zzz", emoji = "💤", description = "Zzz" },

	-- Food & drink
	{ name = "coffee", emoji = "☕", description = "Hot beverage" },
	{ name = "beer", emoji = "🍺", description = "Beer mug" },
	{ name = "pizza", emoji = "🍕", description = "Pizza" },

	-- Nature & weather
	{ name = "sunny", emoji = "☀️", description = "Sun" },
	{ name = "cloud", emoji = "☁️", description = "Cloud" },
	{ name = "cloud_with_rain", emoji = "🌧️", description = "Cloud with rain" },
	{ name = "snowflake", emoji = "❄️", description = "Snowflake" },
	{ name = "evergreen_tree", emoji = "🌲", description = "Evergreen tree" },
	{ name = "cherry_blossom", emoji = "🌸", description = "Cherry blossom" },

	-- Animals
	{ name = "dog", emoji = "🐶", description = "Dog face" },
	{ name = "dog2", emoji = "🐕", description = "Dog" },
	{ name = "cat", emoji = "🐱", description = "Cat face" },
	{ name = "cat2", emoji = "🐈", description = "Cat" },
	{ name = "whale", emoji = "🐳", description = "Spouting whale" },
	{ name = "whale2", emoji = "🐋", description = "Whale" },
	{ name = "unicorn", emoji = "🦄", description = "Unicorn" },

	-- Entertainment
	{ name = "musical_note", emoji = "🎵", description = "Musical note" },
}

-- blink.cmp source interface
M.new = function()
	return setmetatable({}, { __index = M })
end

-- Get completions for the current context
function M:get_completions(context, callback)
	local line = context.line
	local col = context.cursor[2]

	-- Find the last colon before cursor
	local before_cursor = line:sub(1, col)
	local colon_pos = before_cursor:match(".*():")

	if not colon_pos then
		callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
		return
	end

	-- Extract the query after the colon
	local query = before_cursor:sub(colon_pos + 1):lower()

	-- Filter emojis by query
	local items = {}
	for _, emoji_data in ipairs(emojis) do
		if query == "" or emoji_data.name:lower():find(query, 1, true) then
			table.insert(items, {
				label = ":" .. emoji_data.name .. ":",
				kind = require("blink.cmp.types").CompletionItemKind.Text,
				insertText = emoji_data.emoji,
				-- Specify the range to replace: from colon to cursor
				textEdit = {
					newText = emoji_data.emoji,
					range = {
						start = { line = context.cursor[1] - 1, character = colon_pos - 1 },
						["end"] = { line = context.cursor[1] - 1, character = col },
					},
				},
				documentation = {
					kind = "markdown",
					value = string.format("%s %s", emoji_data.emoji, emoji_data.description),
				},
				filterText = emoji_data.name,
			})
		end
	end

	callback({
		is_incomplete_forward = false,
		is_incomplete_backward = false,
		items = items,
	})
end

-- Check if the source should be triggered
function M:should_show_items(context)
	local line = context.line
	local col = context.cursor[2]
	local before_cursor = line:sub(1, col)

	-- Show completions if there's a colon before the cursor
	return before_cursor:match(":") ~= nil
end

return M
