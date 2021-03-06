note
	description: "Action sequence for link actions."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_LINK_ACTION

inherit
	EV_ACTION_SEQUENCE [TUPLE [a_node: EG_LINK]]

create
	default_create

create {EG_LINK_ACTION}
	make_filled

feature -- Element change

	force_extend (a_action: PROCEDURE [ANY, TUPLE])
			-- Extend without type checking.
		do
			extend (agent wrapper (?, a_action))
		end

feature {NONE} -- Implementtion

	wrapper (a_link: EG_LINK; a_action: PROCEDURE [ANY, TUPLE])
			-- Use this to circumvent tuple type checking. (at your own risk!)
			-- Calls `a_action' passing all other arguments.
		do
			a_action (a_link)
		end

	new_filled_list (n: INTEGER): like Current
			-- <Precursor>
		do
			create Result.make_filled (n)
		end

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




end -- class EG_LINK_ACTION

