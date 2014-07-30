note
	description: "Object is a view for an EG_LINKABLE"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_LINKABLE_FIGURE

inherit
	EG_FIGURE
		undefine
			is_equal
		redefine
			default_create,
			recursive_transform,
			model,
			request_update,
			xml_element,
			xml_node_name,
			set_with_xml_element,
			recycle,
			process
		end

	EG_PARTICLE
		rename
			x as port_x,
			y as port_y
		undefine
			default_create,
			port_x,
			port_y
		end

feature {NONE} -- Initialisation

	default_create
			-- Create a EG_LINKABLE_FIGURE.
		do
			create internal_links.make (0)
			Precursor {EG_FIGURE}
			start_actions.extend (agent on_handle_start)
			end_actions.extend (agent on_handle_end)
			set_dt (1)
			mass := 1.0
		end

feature -- Status report

	is_fixed: BOOLEAN assign set_is_fixed
			-- Does the layouter not move `Current'?

	has_visible_link: BOOLEAN
			-- Has `Current' at least one visible link?
		do
			Result := across internal_links as it some it.item.is_show_requested end
		end

	is_cluster_above: BOOLEAN
			-- Is a cluster above `Current'?
		local
			p, q: detachable EG_CLUSTER_FIGURE
			l_bbox: like size
			i, nb: INTEGER
		do
			from
				l_bbox := size
				p := cluster
			until
				Result or p = Void
			loop
				from
					i := p.number_of_figures
					nb := p.count
				until
					i > nb or Result
				loop
					if attached {EG_CLUSTER_FIGURE} p.i_th (i) as c and then q /= c and then c.size.intersects (l_bbox) then
						Result := True
					end
					i := i + 1
				end
				q := p
				p := p.cluster
			end
		end

feature -- Constant

	is_fixed_string: STRING = "IS_FIXED"
			-- Xml mark representing `is_fixed'.

	port_x_string: STRING = "PORT_X"
			-- Xml mark representing `port_x'.

	port_y_string: STRING = "PORT_Y"
			-- Xml mark representing `port_y'.

feature -- Access

	cluster: detachable EG_CLUSTER_FIGURE
			-- Cluster figure `Current' is part of.

	model: EG_LINKABLE
			-- <Precursor>

	port_x: INTEGER
			-- X position where links are starting.
		deferred
		end

	port_y: INTEGER
			-- Y position where links are starting.
		deferred
		end

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := once "EG_LINKABLE_FIGURE"
		end

	xml_element (a_node: like xml_element): XML_ELEMENT
			-- <Precursor>
		local
			l_xml_routines: like xml_routines
		do
			l_xml_routines := xml_routines
			Result := Precursor {EG_FIGURE} (a_node)
			Result.put_last (l_xml_routines.xml_node (Result, is_fixed_string, boolean_representation (is_fixed)))
			Result.put_last (l_xml_routines.xml_node (Result, port_x_string, port_x.out))
			Result.put_last (l_xml_routines.xml_node (Result, port_y_string, port_y.out))
		end

	set_with_xml_element (a_node: like xml_element)
			-- <Precursor>
		local
			l_x, l_y: INTEGER
			l_xml_routines: like xml_routines
		do
			Precursor {EG_FIGURE} (a_node)
			l_xml_routines := xml_routines
			set_is_fixed (l_xml_routines.xml_boolean (a_node, is_fixed_string))

			l_x := l_xml_routines.xml_integer (a_node, port_x_string)
			l_y := l_xml_routines.xml_integer (a_node, port_y_string)
			set_port_position (l_x, l_y)
		end

	size: EV_RECTANGLE
			-- Size of `Current'.
		deferred
		ensure
			result_not_void: Result /= Void
		end

	height: INTEGER
			-- Height in pixels.
		deferred
		end

	width: INTEGER
			-- Width in pixels.
		deferred
		end

	minimum_size: EV_RECTANGLE
			-- `Current' has to be of `Result' size
			-- to include all visible elements starting from `number_of_figures' + 1.
		do
			create Result
			update_rectangle_to_minimum_size (Result)
		ensure
			result_not_void: Result /= Void
		end

	number_of_figures: INTEGER
			-- number of figures used to visialize `Current'.
		deferred
		end

	links: like internal_links
			-- Links to other linkables.
		do
			Result := internal_links.twin
		ensure
			Result_attached: Result /= Void
		end

feature -- Status settings

	request_update
			-- <Precursor>
		do
			Precursor {EG_FIGURE}
			if attached cluster as l_cluster then
				l_cluster.request_update
			end
			across
				internal_links as it
			loop
				it.item.request_update
			end
		end

feature -- Element change

	recycle
			-- <Precursor>
		do
			Precursor {EG_FIGURE}
			start_actions.prune_all (agent on_handle_start)
			end_actions.prune_all (agent on_handle_end)
		end

	set_port_position (a_x, a_y: INTEGER)
			-- Set `port_x' to `a_x' and `port_y' to `a_y'.
		local
			d_x, d_y: INTEGER
		do
			d_x := a_x - port_x
			d_y := a_y - port_y
			set_x_y (x + d_x, y + d_y)
		end

	update_edge_point (p: EV_COORDINATE; a_angle: REAL_64)
			-- Move `p' to a point on the edge of `Current'
			-- where the outline intersects a line from the
			-- center point in direction `a_angle'.
		require
			p_not_void: p /= Void
		deferred
		ensure
			p_not_void: p /= Void
		end

feature -- Status settings

	set_is_fixed (b: like is_fixed)
			-- Set `is_fixed' to `b'.
		do
			is_fixed := b
		ensure
			set: is_fixed = b
		end

feature {EG_FIGURE_WORLD} -- Element change

	add_link (a_link: EG_LINK_FIGURE)
			-- add `a_link' to `links'.
		require
			a_link_not_void: a_link /= Void
		do
			if not internal_links.has (a_link) then
				internal_links.extend (a_link)
			end
		ensure
			links_has_a_link: links.has (a_link)
		end

	remove_link (a_link: EG_LINK_FIGURE)
			-- Remove `a_link' from `links'.
		require
			a_link_not_void: a_link /= Void
		do
			internal_links.prune_all (a_link)
		ensure
			links_not_has_a_link: not links.has (a_link)
		end

feature {EG_CLUSTER_FIGURE, EG_FIGURE_WORLD} -- Element change

	set_cluster (a_cluster: detachable EG_CLUSTER_FIGURE)
			-- set `cluster' to `a_cluster' without adding `Current' to `a_cluster'.
		do
			if attached world as l_world then
				if a_cluster = Void then
					l_world.root_cluster.extend (Current)
					l_world.extend (Current)
				else
					l_world.root_cluster.prune_all (Current)
				end
			end
			if attached cluster as l_cluster then
				l_cluster.prune_all (Current)
			end
			cluster := a_cluster
		ensure
			set: cluster = a_cluster
		end

feature {EV_MODEL_GROUP} -- Figure group

	recursive_transform (a_transformation: EV_MODEL_TRANSFORMATION)
			-- <Precursor>
		do
			Precursor {EG_FIGURE} (a_transformation)
			request_update
		end

feature {EG_LAYOUT, EG_FIGURE, EG_FIGURE_WORLD} -- Implementation

	internal_links: ARRAYED_LIST [EG_LINK_FIGURE]
			-- links to other figures.

feature -- Visitor

	process (v: EG_FIGURE_VISITOR)
			-- Visitor feature.
		do
			v.process_linkable_figure (Current)
		end

feature {NONE} -- Implementation

	on_handle_start
			-- User started to move `Current'
		do
			was_fixed := is_fixed
			set_is_fixed (True)
		end

	on_handle_end
			-- User ended to move `Current'.
		do
			set_is_fixed (was_fixed)
		end

	was_fixed: BOOLEAN
			-- Was previously fixed?

	update_rectangle_to_minimum_size (a_rect: EV_RECTANGLE)
			-- `Current' has to be of `Result' size
			-- to include all visible elements starting from `number_of_figures' + 1.
		local
			l_area: like area
			i, nb: INTEGER
			l_bbox: like bounding_box
		do
				-- Reset `a_bbox' to zero dimension.
			a_rect.move_and_resize (0, 0, 0, 0)
			if count > number_of_figures then
				from
					l_area := area
					i := number_of_figures
					nb := count - 1
				until
					i > nb
				loop
					if l_area [i].is_show_requested then
						l_bbox := temp_minimum_size_bounding_box
						l_area [i].update_rectangle_to_bounding_box (l_bbox)
						if l_bbox.height > 0 and then l_bbox.width > 0 then
							a_rect.merge (l_bbox)
						end
					end
					i := i + 1
				end
			end
		end

	temp_minimum_size_bounding_box: EV_RECTANGLE
			-- Temporary box used for calculating minimum size.
		once
			create Result
		ensure
			Result_attached: Result /= Void
		end

invariant
	internal_links_not_void: internal_links /= Void
	number_of_figures_not_negative: number_of_figures >= 0
	height_not_negative: height >= 0
	width_not_negative: width >= 0

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




end -- class EG_LINKABLE_FIGURE

