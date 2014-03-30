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
	"Use EG_PARTICLE_SIMULATION instead."

inherit
	EG_PARTICLE_SIMULATION [G]

feature {NONE} -- Implementation

	n_body_force_solver (a_particle: EG_PARTICLE): G
			-- Solve n_nody_force O(n)
		local
			l_result: detachable like n_body_force_solver
		do
			across
				particles as it
			loop
				if l_result /= Void then
					l_result := l_result + n_body_force (a_particle, it.item)
				else
					l_result := n_body_force (a_particle, it.item)
				end
				particles.forth
			end
			check l_result /= Void then -- Implied by invariant `particles_not_empty'
				Result := l_result
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

