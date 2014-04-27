note
	description: "[
			Calculating the energy on a particle depending on dt of the particle.

			force := center_attraction * distance (particle_position, center)
					 + sum [for all links l element particle links] stiffnes * link_stiffnes (l) * (distance (particle_position, other_particle_position))^2 / 2
					 + sum [for all particles p element particles] electrical_repulsion / distance (particle_position, other_particle_position)
			where particle position is position of particle + dt * dx/y
				]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_SPRING_ENERGY

inherit
	EG_PARTICLE_SIMULATION_BH [REAL_64]
		redefine
			particle_type
		end

	EV_MODEL_DOUBLE_MATH

	EG_FORCE_DIRECTED_PHYSICS_PROPERTIES

create
	make_with_particles

feature {NONE} -- Implementation

	npx: REAL_64
			-- X position of a particle with dt.

	npy: REAL_64
			-- Y position of a particle with dt.

	external_force (a_node: like particle_type): REAL_64
			-- External force for `a_node'. (attraction to center of universe)
			-- Warning: side-effect query.
		local
			l_dt: REAL_64
		do
			l_dt := a_node.dt
			npx := a_node.port_x + l_dt * a_node.dx
			npy := a_node.port_y + l_dt * a_node.dy
			Result := center_attraction * distance (npx, npy, center_x, center_y)
		ensure then
			npx_set: npx = a_node.port_x + a_node.dt * a_node.dx
			npy_set: npy = a_node.port_y + a_node.dt * a_node.dy
		end

	nearest_neighbor_force (a_node: like particle_type): REAL_64
			-- Spring force between all of `a_node's adjacent nodes.
		local
			l_other: like a_node
			l_edge: EG_LINK_FIGURE
			l_distance: REAL_64
		do
			across
				a_node.links as it
			loop
				l_edge := it.item
				if l_edge.is_show_requested then
					l_other := l_edge.neighbor_of (a_node)
					if l_other.is_show_requested then
						l_distance := distance (npx, npy, l_other.port_x, l_other.port_y)
						Result := Result + stiffness * link_stiffness (l_edge) * (l_distance ^ 2) / 2
					end
				end
			end
		end

	n_body_force (a_node, a_other: EG_PARTICLE): REAL_64
			-- Electrical repulsion between all nodes, including those that are not adjacent.
		do
			if a_node /= a_other then
				Result := electrical_repulsion * a_other.mass / distance (npx, npy, a_other.x, a_other.y).max (0.0001)
			end
		end

feature {NONE} -- Anchor

	particle_type: EG_LINKABLE_FIGURE
			-- <Precursor>
		do
			check callable: False then end
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




end -- class EG_SPRING_ENERGY

