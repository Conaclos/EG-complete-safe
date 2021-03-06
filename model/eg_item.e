note
	description: "The model for a graph item"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_ITEM

inherit
	HASHABLE
		rename
			hash_code as id
		redefine
			default_create,
			is_equal
		end

create
	default_create

feature {NONE} -- Initialization

	default_create
			-- Create an EG_ITEM.
		do
			create name_change_actions
			name_change_actions.compare_objects
		end

feature -- Access

	graph: detachable EG_GRAPH
			-- The graph model `Current' is part of (if not Void).

	id: INTEGER
			-- Unique id.
		do
			if internal_hash_id = 0 then
				counter.put (counter.item + 1)
				internal_hash_id := counter.item
			end
			Result := internal_hash_id
		end

	is_equal (other: like Current): BOOLEAN
			-- Has the same `id' that 'other'?
		do
			Result := id = other.id
		end

	name: detachable STRING
			-- Name of `Current'.

	name_change_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Called when `name' was changed.

feature -- Element change

	set_name (a_name: attached like name)
			-- Set `name' to `a_name'.
		require
			a_name_not_void: a_name /= Void
		do
			if a_name /~ name then
				name := a_name
				name_change_actions.call (Void)
			end
		ensure
			set: a_name /~ name implies name = a_name
		end

feature {EG_GRAPH} -- Element change

	set_graph (a_graph: like graph)
			-- Set `graph' to `a_graph'.
		do
			graph := a_graph
		ensure
			set: graph = a_graph
		end

feature {NONE} -- Implementation

	internal_hash_id: like id
			-- Internal id for the hash code.

	counter: CELL [INTEGER]
			-- Id counter.
		once
			create Result.put (0)
		ensure
			counter_not_void: Result /= Void
		end

invariant
	name_change_actions_not_void: name_change_actions /= Void

note
	copyright:	"Copyright (c) 1984-2014, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end -- class EG_ITEM
