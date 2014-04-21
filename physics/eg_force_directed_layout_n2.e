note
	description: "[
			Objects that arrange nodes using a physical model.
			This algorithm has runtime complexity O(n^2) and is replaced by
			EG_FORCE_DIRECTED_LAYOUT wich does the same with complexity O(n log n).
			]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_FORCE_DIRECTED_LAYOUT_N2

obsolete
	"Use EG_FORCE_DIRECTED_LAYOUT instead."

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
			move_threshold := 10.0
			create stop_actions
		end

feature -- Access

	center_attraction: INTEGER assign set_center_attraction
			-- Attraction of the center in percent.

	stiffness: INTEGER assign set_stiffness
			-- Stiffness in percent.

	electrical_repulsion: INTEGER assign set_electrical_repulsion
			-- Electrical repulsion in percent.

	energy_tolerance: REAL_64
			-- Algorithm variables.
		obsolete
			"Unused."
		attribute end

	center_x: INTEGER
			-- Abscissa position of the center.

	center_y: INTEGER
			-- Ordinate position of the center.

	stop_actions: EV_NOTIFY_ACTION_SEQUENCE

	move_threshold: REAL_64
			-- Stop layouting and call `stop_actions' if no node moved
			-- for more then `move_threshold'.

feature -- Access

	fence: detachable EV_RECTANGLE assign set_fence
			-- Fence to keep nodes in (optional, Void if no fence).

	is_stopped: BOOLEAN
			-- Is stopped?

feature -- Element change

	set_fence (a_fence: like fence)
			-- Set `fence' to `a_fence'.
		do
			fence := a_fence
		ensure
			set: fence = a_fence
		end

	set_move_threshold (d: like move_threshold)
			-- Set `move_threshold' to `d'.
		do
			move_threshold := d
		ensure
			set: move_threshold = d
		end


feature -- Basic operations

	preset (a_level: INTEGER)
			-- Rest the setting accoridingly to `a_level', which is one of:
			-- 1: tight, 2: normal, 3: loose.
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
				set_center_attraction (10)
				set_stiffness (0)
				set_electrical_repulsion (90)
			end
		end

	set_center_attraction (a_value: like center_attraction)
			-- Set `center_attraction' value in percentage of maximum.
		require
			valid_value: 0 <= a_value and a_value <= 100
		do
			center_attraction := a_value
		ensure
			set: center_attraction = a_value
		end

	set_stiffness (a_value: like stiffness)
			-- Set `stiffness' value in percentage of maximum.
		require
			valid_value: 0 <= a_value and a_value <= 100
		do
			stiffness := a_value
		ensure
			set: stiffness = a_value
		end

	set_electrical_repulsion (a_value: like electrical_repulsion)
			-- Set `electrical_repulsion' value in percentage of maximum.
		require
			valid_value: 0 <= a_value and a_value <= 100
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

	reset
			-- Set `is_stopped' to False.
		do
			is_stopped := False
		ensure
			set: not is_stopped
		end

	stop
			-- Set `is_stopped' to True; call `stop_actions'.
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
				max_move := 0.0
				internal_center_attraction := center_attraction / 50
				internal_stiffness := 0.01 + stiffness / 300
				internal_electrical_repulsion := (1 + electrical_repulsion * 200) * (world.scale_factor ^ 1.5)
				layout_linkables (world.nodes, 1, void)
				if max_move < move_threshold * world.scale_factor ^ 0.5  then
					is_stopped := True
					stop_actions.call (Void)
				end
			end
		end

feature {NONE} -- Implementation

	ground_tolerance: REAL_64 = 2.0

	previous_total_energy: REAL_64
		obsolete
			"Unused. [04-2014]"
		attribute end

	total_energy: REAL_64
		obsolete
			"Unused. [04-2014]"
		attribute end

	internal_center_attraction: REAL_64
	internal_stiffness: REAL_64
	internal_electrical_repulsion: REAL_64

	max_move: REAL_64
			-- Maximal move in x and y direction of a node.

	tolerance: REAL_64 = 0.001
			-- Tolerance.

	math: DOUBLE_MATH
			-- Math functions.
		obsolete
			"Unused. [04-2014]"
		once
			create Result
		end

	link_weight (a_link: EG_LINK_FIGURE): REAL_64
			-- Weight of `a_link'
		do
			Result := 0.25 / world.scale_factor
		end

	layout_linkables (a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]; a_level: INTEGER; a_cluster: detachable EG_CLUSTER_FIGURE)
			-- arrange `linkables'.
		local
			l_distance, l_force: REAL_64
			l_item: EG_LINKABLE_FIGURE
			l_other: EG_LINKABLE_FIGURE
			move: REAL_64
			px, py: INTEGER
			opx, opy: INTEGER
			l_edge: EG_LINK_FIGURE
			l_weight: REAL_64
		do
			if not is_stopped then
				across
					a_linkables as it
				loop
					l_item := it.item
					if l_item.is_show_requested and then not l_item.is_fixed then
						px := l_item.port_x
						py := l_item.port_y

						if internal_center_attraction > 0 then
							l_distance := distance (center_x, center_y, px, py)
							if l_distance > 0.1 then
								l_force := - internal_center_attraction / l_distance
								l_item.set_delta (l_item.dx + l_force * (px - center_x), l_item.dy + l_force * (py - center_y))
							end
						end

						across
							l_item.links as it_2
						loop
							l_edge := it_2.item
							if l_edge.is_show_requested then
								l_other := l_edge.neighbor_of (l_item)
								if l_other.is_show_requested then
									opx := l_other.port_x
									opy := l_other.port_y
									l_distance := distance (px, py, opx, opy)
									if l_distance > tolerance then
										l_weight := internal_stiffness * link_weight (l_edge)
										l_item.set_delta (l_item.dx - l_weight * (px - opx), l_item.dy - l_weight * (py - opy))
									end
								end
							end
						end

						across
							a_linkables as it_3
						loop
							l_other := it_3.item
							if
								l_other.is_show_requested and
								l_other /= l_item
							then
								opx := l_other.port_x
								opy := l_other.port_y

								l_distance := distance (px, py, opx, opy).max (tolerance)

								l_force := internal_electrical_repulsion / (l_distance^3)
								l_item.set_delta (l_item.dx + l_force  * (px - opx), l_item.dy + l_force *  (py - opy))
							end
						end

						recursive_energy (l_item, a_linkables)
						move := (l_item.dt * l_item.dx).abs + (l_item.dt * l_item.dy).abs
						max_move := move.max (max_move)
						l_item.set_x_y ((l_item.x + l_item.dx * l_item.dt).truncated_to_integer, (l_item.y + l_item.dy * l_item.dt).truncated_to_integer)
						l_item.set_delta (0, 0)
					end
				end
			end
		end

	repulse (a_node, a_other: EG_LINKABLE_FIGURE)
			-- Get the electrical repulsion between all nodes, including those that are not adjacent.
		local
			l_distance, l_force: REAL_64
			npx, npy, opx, opy: INTEGER
		do
			if a_node /= a_other then
				npx := a_node.port_x
				npy := a_node.port_y
				opx := a_other.port_x
				opy := a_other.port_y
				l_distance := tolerance.max (distance (npx, npy, opx, opy))
				l_force := internal_electrical_repulsion / l_distance / l_distance / l_distance
				a_node.set_delta (a_node.dx + l_force  * (npx - opx), a_node.dy + l_force *  (npy - opy))
			end
		end

	attract_connected (a_node: EG_LINKABLE_FIGURE; a_edge: EG_LINK_FIGURE)
			-- Get the spring force between all of its adjacent nodes.
		local
			l_distance: REAL_64
			l_other: EG_LINKABLE_FIGURE
			l_weight: REAL_64
			npx, npy, opx, opy: REAL_64
		do
			l_other := a_edge.neighbor_of (a_node)
			if l_other.is_show_requested then
				npx := a_node.port_x
				npy := a_node.port_y
				opx := l_other.port_x
				opy := l_other.port_y
				l_distance := distance (npx, npy, opx, opy)
				if l_distance > tolerance then
					l_weight := link_weight (a_edge)
					a_node.set_delta (a_node.dx - internal_stiffness * l_weight * (npx - opx), a_node.dy - internal_stiffness * l_weight * (npy - opy))
				end
			end
		end

	recursive_energy (a_node: EG_LINKABLE_FIGURE; a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE])
		require
			a_node_not_void: a_node /= Void
			a_linkables_not_void: a_linkables /= Void
			a_node_is_shown_requested: a_node.is_show_requested
		local
			l_initial_energy, l_dt, l_energy: REAL_64
			i: INTEGER
			l_other: like a_node
			l_edge: EG_LINK_FIGURE
			l_distance, l_distance2: REAL_64
			npx, npy: REAL_64
			ox, oy, px, py: INTEGER
			l_weight: REAL_64
		do
			l_dt := a_node.dt * 2
			a_node.set_dt (l_dt)

			px := a_node.port_x
			py := a_node.port_y
			npx := a_node.port_x + l_dt * a_node.dx
			npy := a_node.port_y + l_dt * a_node.dy
			l_energy := internal_center_attraction * distance (npx, npy, center_x, center_y)
			l_initial_energy := internal_center_attraction * distance (px, py, center_x, center_y)
			across
				a_linkables as it
			loop
				l_other := it.item
				if a_node /= l_other and l_other.is_show_requested then
					ox := l_other.port_x
					oy := l_other.port_y
					l_energy :=  l_energy + internal_electrical_repulsion / distance (npx, npy, ox, oy).max (0.0001)
					l_initial_energy :=  l_initial_energy + internal_electrical_repulsion / distance (px, py, ox, oy).max (0.0001)
				end
			end

			across
				a_node.links as it
			loop
				l_edge := it.item
				if l_edge.is_show_requested then
					l_other := l_edge.neighbor_of (a_node)
					if l_other.is_show_requested then
						ox := l_other.port_x
						oy := l_other.port_y
						l_weight := internal_stiffness * link_weight (l_edge)

						l_distance := distance (npx, npy, ox, oy)
						l_distance2 := distance (px, py, ox, oy)

						l_energy := l_energy +  l_weight * l_distance * l_distance / 2
						l_initial_energy := l_initial_energy + l_weight * l_distance2 * l_distance2 / 2
					end
				end
			end

			check
				l_energy = node_energy (a_node, l_dt, a_linkables)
				l_initial_energy = node_energy (a_node, 0, a_linkables)
			end

			from
				i := 0
			until
				l_energy <= l_initial_energy or else i > 4
			loop
				i := i + 1
				l_dt := l_dt / 4
				l_energy := node_energy (a_node, l_dt, a_linkables)
			end
			a_node.set_dt (l_dt)
		end

	node_energy (a_node: EG_LINKABLE_FIGURE; a_dt: REAL_64; a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]): REAL_64
		require
			a_node_not_void: a_node /= Void
			a_linkables_not_void: a_linkables /= Void
			a_node_is_shown_requested: a_node.is_show_requested
		local
			l_other: like a_node
			l_edge: EG_LINK_FIGURE
			l_distance: REAL_64
			npx, npy: REAL_64
		do
			npx := a_node.port_x + a_dt * a_node.dx
			npy := a_node.port_y + a_dt * a_node.dy
			Result := internal_center_attraction * distance (npx, npy, center_x, center_y)
			across
				a_linkables as it
			loop
				l_other := it.item
				if l_other /= a_node and then l_other.is_show_requested then
					Result :=  Result + internal_electrical_repulsion / distance (npx, npy, l_other.port_x, l_other.port_y).max (0.0001)
				end
			end

			across
				a_node.links as it
			loop
				l_edge := it.item
				if l_edge.is_show_requested then
					l_other := l_edge.neighbor_of (a_node)
					if l_other.is_show_requested then
						l_distance := distance (npx, npy, l_other.port_x, l_other.port_y)
						Result := Result + internal_stiffness * link_weight (l_edge) * l_distance * l_distance / 2
					end
				end
			end
		end

invariant
	valid_center_attraction: 0 <= center_attraction and center_attraction <= 100
	valid_electrical_repulsion: 0 <= electrical_repulsion and electrical_repulsion <= 100
	valid_stiffness: 0 <= stiffness and stiffness <= 100

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




end -- class EG_FORCE_DIRECTED_LAYOUT_N2

