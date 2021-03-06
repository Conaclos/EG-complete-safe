note
	description: "[
			EG_FORCE_DIRECTED_LAYOUT is a force directed layout using a spring particle system and
			a Barnes and Hut solver. The complexity is therfore O(n log n) where n is the number of
			linkables.

			Links between nodes behave as if they where springs.
				The higher `stiffness' the stronger the springs.

			All nodes are repulsing each other from each other as if they where magnets with same polarity.
				The higher `electrical_repulsion' the stronger the repulsion.

			All nodes fall into the center.
				The position of the center is (`center_x', `center_y') and the higher `center_attraction'
				the faster the nodes fall into the center.

			`theta' is the error variable for Barnes and Hut where 0 is low error and slow calculation and
				100 is high error and fast calculation.

				]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_FORCE_DIRECTED_LAYOUT

inherit
	EG_LAYOUT
		redefine
			default_create,
			layout
		end

	EV_MODEL_DOUBLE_MATH
		undefine
			default_create
		end

create
	make_with_world

feature {NONE} -- Initialization

	default_create
			-- Create a EG_FORCE_DIRECTED_LAYOUT.
		do
			Precursor {EG_LAYOUT}
			preset (3)
			move_threshold := 10
			theta :=  25
			create stop_actions
		end

feature -- Status report

	is_stopped: BOOLEAN
			-- Is stopped?

feature -- Access

	center_attraction: NATURAL_8 assign set_center_attraction
			-- Attraction of the center in percent.

	center_x: INTEGER
			-- X position of the center.

	center_y: INTEGER
			-- Y position of the center.

	stiffness: NATURAL_8 assign set_stiffness
			-- Stiffness of the links in percent.

	electrical_repulsion: NATURAL_8 assign set_electrical_repulsion
			-- Electrical repulsion between nodes in percent.

	stop_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Called when the layouting stops.

	move_threshold: NATURAL assign set_move_threshold
			-- Call `stop_actions' if no node moved.
			-- for more then `move_threshold'

	theta: NATURAL_8 assign set_theta
			-- Error variable for Barnes and Hut.

	last_theta_average: REAL_64
			-- Average theta value after last call to `layout'.

feature -- Element change

	preset (a_level: INTEGER)
			-- Rest the setting accordingly to `a_level', which is one of:
			-- 1: tight, 2: normal, 3: loose
		do
			if a_level = 1 then
				-- Tight
				set_center_attraction (90)
				set_stiffness (100)
				set_electrical_repulsion (30)
			elseif a_level = 2 then
				-- Normal
				set_center_attraction (50)
				set_stiffness (50)
				set_electrical_repulsion (50)
			elseif a_level = 3 then
				-- Loose
				set_center_attraction (15)
				set_stiffness (2)
				set_electrical_repulsion (100)
			end
		end

	set_move_threshold (d: like move_threshold)
			-- Set `move_threshold' to `d'.
		do
			move_threshold := d
		ensure
			set: move_threshold = d
		end

	set_theta (a_theta: like theta)
			-- Set `theta' to `a_theta'.
		require
			valid_value: a_theta <= 100
		do
			theta := a_theta
		end

	set_center_attraction (a_value: like center_attraction)
			-- Set 'center_attraction' value in percentage of maximum.
		require
			valid_value: a_value <= 100
		do
			center_attraction := a_value
		ensure
			set: center_attraction = a_value
		end

	set_stiffness (a_value: like stiffness)
			-- Set 'stiffness' value in percentage of maximum.
		require
			valid_value: a_value <= 100
		do
			stiffness := a_value
		ensure
			set: stiffness = a_value
		end

	set_electrical_repulsion (a_value: like electrical_repulsion)
			-- Set 'electrical_repulsion' value in percentage of maximum.
		require
			valid_value: a_value <= 100
		do
			electrical_repulsion := a_value
		ensure
			set: electrical_repulsion = a_value
		end

	set_center (a_x, a_y: INTEGER)
			-- Set `center_x' to `a_x' and `center_y' to `a_y'.
		do
			center_x := a_x
			center_y := a_y
		ensure
			set: center_x = a_x and center_y = a_y
		end

feature -- Basic operations

	reset
			-- Set `is_stopped' to False.
		do
			is_stopped := False
			iterations := 0
		ensure
			set: not is_stopped
		end

	stop
			-- Set `is_stopped' to True, call `stop_actions'.
		do
			is_stopped := True
			stop_actions.call (Void)
		ensure
			set: is_stopped
		end

	layout
			-- <Precursor>
		do
			if not is_stopped then
				if world.nodes.is_empty then
					is_stopped := True
					stop_actions.call (Void)
				else
					max_move := 0
					last_theta_average := 0.0
					theta_count := 0

					layout_linkables (world.nodes, 1, Void)

					if max_move < move_threshold * world.scale_factor ^ 0.5 and iterations > 10 then
						is_stopped := True
						stop_actions.call (Void)
					else
						iterations := iterations + 1
					end
					if theta_count > 0 then
						last_theta_average := last_theta_average / theta_count
					end
				end
			else
				last_theta_average := 0.0
			end
		end

feature {NONE} -- Implementation

	max_move: NATURAL
			-- Maximal move in x and y direction of a node.

	theta_count: NATURAL
			-- Theta count.

	iterations: NATURAL
			-- Number of iterations.

	layout_linkables (a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]; a_level: INTEGER; a_cluster: detachable EG_CLUSTER_FIGURE)
			-- arrange `a_linkables'.
		local
			l_item: EG_LINKABLE_FIGURE
			l_force: EG_VECTOR2D [REAL_64]
			dx, dy: INTEGER
			l_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]
			l_particle: EG_SPRING_PARTICLE
			l_energy: EG_SPRING_ENERGY
		do
			if not is_stopped then
					-- Filter out not visible nodes
				create l_linkables.make (a_linkables.count)
				across
					a_linkables as it
				loop
					l_item := it.item
					if l_item.is_show_requested then
						l_linkables.extend (l_item)
					end
				end

				if not l_linkables.is_empty then
						-- Initialize particle solvers
					l_particle := new_spring_particle_solver (l_linkables)
					l_energy := new_spring_energy_solver (l_linkables)

						-- solve system
					across
						l_linkables as it
					loop
						l_item := it.item
						if not l_item.is_fixed then
								-- Calculate spring force
							l_force := l_particle.force (l_item)
							l_item.set_delta (l_force.x, l_force.y)
								-- Update statistic
							last_theta_average := last_theta_average + l_particle.last_theta_average
							theta_count := theta_count + 1

								-- Calculate spring energy
							recursive_energy (l_item, l_energy)

								-- Move item
							dx := (l_item.dt * l_item.dx).truncated_to_integer
							dy := (l_item.dt * l_item.dy).truncated_to_integer

							max_move := max_move.max ((dx.abs + dy.abs).as_natural_32)

							l_item.set_x_y (l_item.x + dx, l_item.y + dy)
							l_item.set_delta (0, 0)
						end
					end
				end
			end
		end

	recursive_energy (a_node: EG_LINKABLE_FIGURE; a_solver: EG_SPRING_ENERGY)
			-- Calculate spring energy for `a_node'.
		local
			i: INTEGER
			l_energy, l_initial_energy: REAL_64
			l_dt: REAL_64
		do
			l_dt := a_node.dt

			a_node.set_dt (0)
			l_initial_energy := a_solver.force (a_node)
			last_theta_average := last_theta_average + a_solver.last_theta_average
			theta_count := theta_count + 1

			l_dt := l_dt * 2
			a_node.set_dt (l_dt)
			l_energy := a_solver.force (a_node)
			last_theta_average := last_theta_average + a_solver.last_theta_average
			theta_count := theta_count + 1

			from
				i := 0
			until
				l_energy <= l_initial_energy or else i > 4
			loop
				i := i + 1
				l_dt := l_dt / 4
				a_node.set_dt (l_dt)
				l_energy := a_solver.force (a_node)
				last_theta_average := last_theta_average + a_solver.last_theta_average
				theta_count := theta_count + 1
			end
		end

	new_spring_particle_solver (a_particles: LIST [EG_LINKABLE_FIGURE]): EG_SPRING_PARTICLE
			-- Create a new spring particle solver for `a_particles' and initialize it.
		require
			particles_exist: a_particles /= Void
			particles_not_empty: not a_particles.is_empty
		local
			l_center_attraction, l_stiffness, l_electrical_repulsion: REAL_64
		do
			l_center_attraction := center_attraction / 25
			l_stiffness := ((stiffness / 300) * 0.5).max (0.0001) / world.scale_factor
			l_electrical_repulsion := (1 + electrical_repulsion * 400) * (world.scale_factor ^ 1.5)

			create Result.make_with_particles (a_particles)

			Result.set_center (center_x, center_y)
			Result.set_center_attraction (l_center_attraction)
			Result.set_electrical_repulsion (l_electrical_repulsion)
			Result.set_stiffness (l_stiffness)
			Result.set_theta (theta / 100)
		ensure
			Result_exists: Result /= Void
		end

	new_spring_energy_solver (a_particles: LIST [EG_LINKABLE_FIGURE]): EG_SPRING_ENERGY
			-- Create a new spring energy solver for `particles' and initialize it.
		require
			particles_exist: a_particles /= Void
			particles_not_empty: not a_particles.is_empty
		local
			l_center_attraction, l_stiffness, l_electrical_repulsion: REAL_64
		do
			l_center_attraction := center_attraction / 25
			l_stiffness := ((stiffness / 300) * 0.5).max (0.0001) / world.scale_factor
			l_electrical_repulsion := (1 + electrical_repulsion * 400) * (world.scale_factor ^ 1.5)

			create Result.make_with_particles (a_particles)

			Result.set_center (center_x, center_y)
			Result.set_center_attraction (l_center_attraction)
			Result.set_electrical_repulsion (l_electrical_repulsion)
			Result.set_stiffness (l_stiffness)
			Result.set_theta (theta / 100)
		ensure
			Result_exists: Result /= Void
		end

invariant
	valid_theta: theta <= 100
	positive_last_theta_average: last_theta_average >= 0.0
	valid_center_attraction: center_attraction <= 100
	valid_electrical_repulsion: electrical_repulsion <= 100
	valid_stiffness: stiffness <= 100

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




end -- class EG_FORCE_DIRECTED_LAYOUT

