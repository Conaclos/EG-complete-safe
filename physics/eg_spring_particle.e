note
	description: "[
			Calculate spring force for a particle.
			force := - center_attraction * (particle_position - center) / distance (particle_position, center)
					+ sum [for all links l element particle link] - (stiffness * link_stiffness (l) * (particle_position - other_position))
					+ sum [for all particle p element particles] electrical_repulsion * (particle_position - other_position) / distance (particle_position, other_position)^3
			]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_SPRING_PARTICLE

inherit
	EG_PARTICLE_SIMULATION_BH [EG_VECTOR2D [REAL_64]]
		redefine
			particle_type
		end

	EV_MODEL_DOUBLE_MATH

	EG_FORCE_DIRECTED_PHYSICS_PROPERTIES

create
	make_with_particles

feature {NONE} -- Implementation

	px: INTEGER
			-- X position of a particle.

	py: INTEGER
			-- Y position of a particle.

	external_force (a_node: like particle_type): EG_VECTOR2D [REAL_64]
			-- External force for `a_node'. (attraction to center of universe).
			-- Warning: side-effect query.
		local
			l_distance: REAL_64
			l_force: REAL_64
		do
			px := a_node.port_x
			py := a_node.port_y

			l_distance := distance (center_x, center_y, px, py)
			if l_distance > 0.1 then
				l_force := - center_attraction / l_distance
				create Result.make (l_force * (px - center_x), l_force * (py - center_y))
			else
				create Result.make (0.0, 0.0)
			end
		ensure then
			px_set: px = a_node.port_x
			py_set: py = a_node.port_y
		end

	nearest_neighbor_force (a_node: like particle_type): EG_VECTOR2D [REAL_64]
			-- Spring force between all of `a_node's adjacent nodes.
		local
			l_item: EG_LINK_FIGURE
			l_other: EG_LINKABLE_FIGURE
			l_weight: REAL_64
			x, y: REAL_64
		do
			across
				a_node.links as it
			loop
				l_item := it.item
				if l_item.is_show_requested then
					l_other := l_item.neighbor_of (a_node)
					if l_other.is_show_requested then
						l_weight := stiffness * link_stiffness (l_item)
						x := x - l_weight * (px - l_other.port_x)
						y := y - l_weight * (py - l_other.port_y)
					end
				end
			end
			create Result.make (x, y)
		end

	n_body_force (a_node, a_other: EG_PARTICLE): EG_VECTOR2D [REAL_64]
			-- Electrical repulsion between all nodes, including those that are not adjacent.
		local
			l_distance, l_force: REAL_64
			opx, opy: REAL_64
		do
			if a_node = a_other then
				create Result.make (0.0, 0.0)
			else
				opx := a_other.x
				opy := a_other.y
				l_distance := distance (px, py, opx, opy).max (0.001)

				l_force := electrical_repulsion / (l_distance ^ 3)
				create Result.make (l_force * (px - opx) * a_other.mass, l_force * (py - opy) * a_other.mass)
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




end -- class EG_SPRING_PARTICLE

