note
	description: "Objects that is a straight forward implementation for an `n_body_force_solver' O(n^2)"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_PARTICLE_SIMULATION_N2 [G -> NUMERIC]

obsolete
	"Use EG_PARTICLE_SIMULATION instead. [before 2014]"

inherit
	EG_PARTICLE_SIMULATION [G]

feature {NONE} -- Implementation

	n_body_force_solver (a_particle: EG_PARTICLE): G
			-- Solve n_nody_force O(n).
		local
			it: INDEXABLE_ITERATION_CURSOR [like particle_type]
		do
			from
				it := particles.new_cursor
				Result := n_body_force (a_particle, it.item)
				it.forth
			until
				it.after
			loop
				Result := Result + n_body_force (a_particle, it.item)
				it.forth
			end
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




end -- class EG_PARTICLE_SIMULATION_N2

