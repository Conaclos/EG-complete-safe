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
	EG_PARTICLE_SIMULATION_BH [DOUBLE]
		redefine
			particle_type
		end

	EV_MODEL_DOUBLE_MATH
		undefine
			default_create
		end

	EG_FORCE_DIRECTED_PHYSICS_PROPERTIES
		undefine
			default_create
		end

create
	make_with_particles

feature {NONE} -- Implementation

	npx, npy: DOUBLE
			-- Position of a particle with dt.

	external_force (a_node: like particle_type): DOUBLE
			-- External force for `a_node'. (attraction to center of universe)
			-- Warning: side-effect query.
		local
			l_dt: DOUBLE
		do
			l_dt := a_node.dt
			npx := a_node.port_x + l_dt * a_node.dx
			npy := a_node.port_y + l_dt * a_node.dy
			Result := center_attraction * distance (npx, npy, center_x, center_y)
		ensure then
			npx_set: npx = a_node.port_x + a_node.dt * a_node.dx
			npy_set: npy = a_node.port_y + a_node.dt * a_node.dy
		end

	nearest_neighbor_force (a_node: like particle_type): DOUBLE
			-- Get the spring force between all of `a_node's adjacent nodes.
		local
			i, nb: INTEGER
			links: ARRAYED_LIST [EG_LINK_FIGURE]
			l_other: like a_node
			l_edge: EG_LINK_FIGURE
			l_distance: DOUBLE
		do
			from
				links := a_node.links
				i := 1
				nb := links.count
			until
				i > nb
			loop
				l_edge := links.i_th (i)
				if l_edge.is_show_requested then
					if a_node = l_edge.source then
						l_other := l_edge.target
					else
						l_other := l_edge.source
					end
					if l_other.is_show_requested then
						l_distance := distance (npx, npy, l_other.port_x, l_other.port_y)
						Result := Result + stiffness * link_stiffness (l_edge) * (l_distance^2) / 2
					end
				end
				i := i + 1
			end
		end

	n_body_force (a_node, an_other: EG_PARTICLE): DOUBLE
			-- Get the electrical repulsion between all nodes, including those that are not adjacent.
		do
			if a_node /= an_other then
				Result := electrical_repulsion * an_other.mass / distance (npx, npy, an_other.x, an_other.y).max (0.0001)
			end
		end

feature {NONE} -- Implementation

	particle_type: EG_LINKABLE_FIGURE
			-- Type of particle
		do
			check anchor_type_only: False then end
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

