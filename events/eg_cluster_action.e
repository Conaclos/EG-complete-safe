note
	description: "Action sequence for cluster actions."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_CLUSTER_ACTION

inherit
	EV_ACTION_SEQUENCE [TUPLE [a_node: EG_CLUSTER]]

create
	default_create

create {EG_CLUSTER_ACTION}
	make_filled

feature -- Access

	wrapper (a_cluster: EG_CLUSTER; action: PROCEDURE [ANY, TUPLE])
			-- Use this to circumvent tuple type checking. (at your own risk!)
			-- Calls `action' passing all other arguments.
		do
			action (a_cluster)
		end

	new_filled_list (n: INTEGER): like Current
			-- New list with `n' elements.
		do
			create Result.make_filled (n)
		end

feature -- Element change

	force_extend (action: PROCEDURE [ANY, TUPLE])
			-- Extend without type checking.
		do
			extend (agent wrapper (?, action))
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




end -- class EG_CLUSTER_ACTION

