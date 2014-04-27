note
	description: "[
			This is the Barnes and Hut implementation for the n_body_force_solver of
			a particle system. The runtime is O (n log n) where n is the number of particles.
			The method was first proposed in:
			"A Hierarchical O(n log n) force calculation algorithm", J. Barnes and P. Hut, Nature, v. 324 (1986)

			To calculate the force on a_particle an EG_QUAD_TREE (node) is traversed where force is either

				traverse (node):
					1. if node is a leaf
						force := n_body_force (a_particle, node.particle)
					2. size of node region / distance between a_particle and center of mass of node < theta
						force := n_body_force (a_particle, node.center_of_mass_particle)
					3. none of the above
						for all children c of node
							force := force + traverse (c)

			The larger theta the better the runtime but also the higher the error since center_of_mass_particle
			is only an approximation of all the particle in the children of node.

				]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_PARTICLE_SIMULATION_BH [G -> NUMERIC]

inherit
	EG_PARTICLE_SIMULATION [G]
		redefine
			make_with_particles,
			set_particles
		end

inherit {NONE}
	EV_MODEL_DOUBLE_MATH
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	make_with_particles (a_particles: like particles)
			-- <Precursor>
		do
			theta := 0.25
			set_particles (a_particles)
		ensure then
			theta_set: theta = 0.25
			particles_set: particles = a_particles
		end

feature -- Access

	quad_tree: EG_QUAD_TREE
			-- The quad tree to traverse.

	theta: REAL_64 assign set_theta
			-- The higher theta the more approximations are made (see comment in indexing).

	last_theta_average: REAL_64
			-- The average theta value on last call to `force'.

feature -- Element change.

	set_particles (a_particles: like particles)
			-- Set `particles' to `a_particles' and build `quad_tree'.
		do
			Precursor (a_particles)
			build_quad_tree
		end

	set_theta (a_theta: like theta)
			-- Set `theta' to `a_theta'.
		require
			a_theta_in_range: 0.0 <= theta and theta <= 1.0
		do
			theta := a_theta
		ensure
			set: theta = a_theta
		end

feature {NONE} -- Implementation

	theta_count: NATURAL
			-- Number of times theta was below 1.0.

	n_body_force_solver (a_particle: like particle_type): G
			-- Solve n_nody_force O(log n) best case O(n) worste case.
		do
			last_theta_average := 0.0
			theta_count := 0
			Result := traverse_tree (quad_tree, a_particle)
			if theta_count > 0 then
				last_theta_average := last_theta_average / theta_count
			end
		end

	traverse_tree (a_node: EG_QUAD_TREE; a_particle: like particle_type): G
			-- Traverse `node' and calculate force with `a_particle'.
		require
			not_void: a_node /= Void
		local
			r: REAL_64
			d: INTEGER
			l_prop: REAL_64
			l_region: EV_RECTANGLE
			l_result: detachable like traverse_tree
			l_cmp: EG_PARTICLE
		do
			if attached a_node.particle as l_particle then
				check
					is_leaf: a_node.is_leaf
				end
				Result := n_body_force (a_particle, l_particle)
			else
				l_cmp := a_node.center_of_mass_particle
				l_region := a_node.region
					-- Distance to center of mass
				r := distance (a_particle.x, a_particle.y, l_cmp.x, l_cmp.y)
					-- size of the cell
				d := l_region.width.max (l_region.height)
					-- proportion between distance and size
				l_prop := d / r

				if l_prop < 1.0 then
					last_theta_average := last_theta_average + l_prop
					theta_count := theta_count + 1
				end

				if l_prop < theta then
						-- Approximate
					Result := n_body_force (a_particle, l_cmp)
				else
						-- Inspect children
					if attached a_node.childe_ne as l_childe then
						l_result := traverse_tree (l_childe, a_particle)
					end

					if attached a_node.childe_nw as l_childe_2 then
						if l_result = Void then
							l_result := traverse_tree (l_childe_2, a_particle)
						else
							l_result := l_result + traverse_tree (l_childe_2, a_particle)
						end
					end

					if attached a_node.childe_se as l_childe_3 then
						if l_result = Void then
							l_result := traverse_tree (l_childe_3, a_particle)
						else
							l_result := l_result + traverse_tree (l_childe_3, a_particle)
						end
					end

					if l_result = Void then
						check attached a_node.childe_sw as l_childe_4 then -- Implied by not node.is_leaf
							Result := traverse_tree (l_childe_4, a_particle)
						end
					elseif attached a_node.childe_sw as l_childe_4 then
						Result := l_result + traverse_tree (l_childe_4, a_particle)
					else
						Result := l_result
					end
				end
			end
		ensure
			Result_exists: Result /= Void
		end

	build_quad_tree
			-- Build `quad_tree' from `particles'. O(n log n).
		local
			l_item: like particle_type
			world_size: EV_RECTANGLE
			maxx, minx, maxy, miny, x, y: INTEGER
			l_quad_tree: like quad_tree
			it_2: INDEXABLE_ITERATION_CURSOR [like particle_type]
		do
			maxx := maxx.min_value
			maxy := maxx
			minx := minx.max_value
			miny := minx
			across particles as it loop
				l_item := it.item
				x := l_item.x
				maxx := maxx.max (x)
				minx := minx.min (x)
				y := l_item.y
				maxy := maxy.max (y)
				miny := miny.min (y)
			end
			create world_size.make (minx, miny, maxx - minx, maxy - miny)
			from
				it_2 := particles.new_cursor
				create l_quad_tree.make (world_size, it_2.item)
				it_2.forth
			until
				it_2.after
			loop
				l_item := it_2.item
				if not l_quad_tree.has (l_item) then
					l_quad_tree.insert (l_item)
				end
				it_2.forth
			end
			quad_tree := l_quad_tree
		end

invariant
	valid_theta: 0.0 <= theta and theta <= 1.0
	positive_last_theta_average: 0.0 <= last_theta_average
	quad_tree_exists: quad_tree /= Void

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




end -- class EG_PARTICLE_SIMULATION_BH

