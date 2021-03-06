note
	description: "Objects that is a vector containing NUMERICs."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_VECTOR [G -> NUMERIC]

inherit
	NUMERIC
		rename
			product as scalar_product alias "*"
		end

feature -- Basic operations

	scalar_product alias "*" (other: like Current): like Current
			-- Dot product betwen `Current' and `other'.
		deferred
		end

	product alias "|*" (a_value: G): like Current
			-- Product between `Current' and `a_value'.
		deferred
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




end -- class EG_VECTOR

