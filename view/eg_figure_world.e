note
	description: "Objects that is a view for an EG_GRAPH"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_FIGURE_WORLD

inherit
	EV_MODEL_WORLD
		redefine
			default_create,
			scale,
			wipe_out,
			new_filled_list,
			create_interface_objects
		end

	EG_XML_STORABLE
		undefine
			default_create
		end

	EV_SHARED_APPLICATION
		export
			{NONE} all
		undefine
			default_create
		end

create
	make_with_model_and_factory,
	make_with_model

feature {NONE} -- Initialization

	create_interface_objects
			-- <Precursor>
		do
			create linkables_to_figures.make (30)
			create links_to_figures.make (20)
			create root_cluster.make (10)
			create nodes.make (50)
			create selected_figures.make (5)
			create links.make (50)
			create clusters.make (10)
			create figure_change_end_actions
			create figure_change_start_actions
			Precursor {EV_MODEL_WORLD}
		end

	default_create
			-- Create an EG_FIGURE_WORLD.
		do
			Precursor {EV_MODEL_WORLD}
			scale_factor := 1.0
			pointer_button_press_actions.extend (agent on_pointer_button_press_on_world)
			pointer_button_release_actions.extend (agent on_pointer_button_release_on_world)
			pointer_motion_actions.extend (agent on_pointer_motion_on_world)
			is_multiple_selection_enabled := True
			xml_routines.reset_valid_tags
			real_grid_x := default_grid_x
			real_grid_y := default_grid_y
		end

	make_with_model_and_factory (a_model: like model; a_factory: like factory)
			-- Create a view for `a_model' using `a_factory'.
		require
			a_model_not_void: a_model /= Void
			a_factory_not_void: a_factory /= Void
		do
			model := a_model
			factory := a_factory
			default_create
			a_factory.set_world (Current)
			-- create all views in model

			if a_model.clusters.is_empty then
				across
					a_model.nodes as it
				loop
					add_node (it.item)
				end
			else
				across
					a_model.clusters as it
				loop
					if it.item.cluster = Void then
						insert_cluster (it.item)
					end
				end
			end

			across
				a_model.links as it
			loop
				add_link (it.item)
			end

			-- create new views when required
			model.node_add_actions.extend (agent add_node)
			model.link_add_actions.extend (agent add_link)
			model.cluster_add_actions.extend (agent add_cluster)

			model.link_remove_actions.extend (agent remove_link)
			model.node_remove_actions.extend (agent remove_node)
			model.cluster_remove_actions.extend (agent remove_cluster)

			enable_grid
		ensure
			model_set: model = a_model
			factory_set: factory = a_factory
		end

	make_with_model (a_model: like model)
			-- Create a view for `a_model' using EG_SIMPLE_FACTORY.
		require
			a_model_not_void: a_model /= Void
		do
			make_with_model_and_factory (a_model, create {EG_SIMPLE_FACTORY})
		ensure
			set: model = a_model
		end

feature -- Status Report

	has_linkable_figure (a_linkable: EG_LINKABLE): BOOLEAN
			-- Does `a_linkable' have a view in `Current'?
		require
			a_linkable_not_void: a_linkable /= Void
		do
			Result := linkables_to_figures.has (a_linkable)
		end

	has_node_figure (a_node: EG_NODE): BOOLEAN
			-- Does `a_node' have a view in `Current'?
		obsolete
			"Use `has_linkable_figure' instead; [04-2014]"
		require
			a_node_not_void: a_node /= Void
		do
			Result := has_linkable_figure (a_node)
		end

	has_link_figure (a_link: EG_LINK): BOOLEAN
			-- Does `a_link' have a view in `Current'?
		require
			a_link_not_void: a_link /= Void
		do
			Result := links_to_figures.has (a_link)
		end

	has_cluster_figure (a_cluster: EG_CLUSTER): BOOLEAN
			-- Does `a_cluster' have a view in `Current'?
		require
			a_cluster_not_void: a_cluster /= Void
		do
			Result := attached {EG_CLUSTER_FIGURE} linkables_to_figures.item (a_cluster)
		end

	is_multiple_selection_enabled: BOOLEAN
			-- Can the user select multiple figures with a rectangle?

	selected_figures_in_world: BOOLEAN
			-- Are all figures in `selected_figures' part of `Current'?
		do
			Result := across selected_figures as it all has_deep (it.item) end
		end

feature -- Access

	figure_from_model (a_item: EG_ITEM): detachable EG_FIGURE
			-- Return the view for `a_item' if any.
		require
			an_item_not_void: a_item /= Void
		do
			if attached {EG_LINKABLE} a_item as l_linkable then
				Result := linkables_to_figures.item (l_linkable)
			elseif attached {EG_LINK} a_item as l_link then
				Result := links_to_figures.item (l_link)
			end
		end

	model: EG_GRAPH
			-- Model for `Current'.

	attached_model: like model
			-- `model'.
		obsolete
			"Use `model' instead. [03-2014]"
		do
			Result := model
		end

	factory: EG_FIGURE_FACTORY
			-- Factory used to create new figures.

	attached_factory: like factory
			-- `factory'.
		obsolete
			"Use `factory' instead. [03-2014]"
		do
			Result := factory
		end

	flat_links: like links
			-- All links in the view.
		do
			Result := links.twin
		ensure
			result_not_void: Result /= Void
		end

	flat_nodes: like nodes
			-- All nodes in the view.
		do
			Result := nodes.twin
		ensure
			result_not_void: Result /= Void
		end

	flat_clusters: like clusters
			-- All clusters in the view.
		do
			Result := clusters.twin
		ensure
			result_not_void: Result /= Void
		end

	selected_figures: ARRAYED_LIST [EG_FIGURE]
			-- All currently selected figures.

	scale_factor: REAL_64
			-- `Current' has been scaled for `scale_factor'.

	root_clusters: ARRAYED_LIST [EG_CLUSTER_FIGURE]
			-- All clusters in `Current' not having a parent.
		local
			l_root: like root_cluster
		do
			l_root := root_cluster
			create Result.make (l_root.count)
			across
				l_root as it
			loop
				if attached {EG_CLUSTER_FIGURE} it.item as l_item then
					Result.extend (l_item)
				end
			end
		ensure
			Result_not_Void: Result /= Void
		end

	smallest_common_supercluster (a_fig_1, a_fig_2: EG_LINKABLE_FIGURE): detachable EG_CLUSTER_FIGURE
			-- Smallest common supercluster of `a_fig_1' and `a_fig_2'.
		require
			fig1_not_void: a_fig_1 /= Void
			fig2_not_void: a_fig_2 /= Void
		local
			p, q: detachable EG_CLUSTER_FIGURE
		do
			from
				p := a_fig_1.cluster
			until
				p = Void or Result /= Void
			loop
				from
					q := a_fig_2.cluster
				until
					q = Void or Result /= Void
				loop
					if p = q then
						Result := p
					end
					q := q.cluster
				end
				p := p.cluster
			end
		end

	figure_change_start_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- A figure will be moved or changed by the user.

	figure_change_end_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- A figure is not moved or changed anymore by user.

feature -- Status settings

	disable_multiple_selection
			-- Set `is_multiple_selection_enabed' to False.
		do
			is_multiple_selection_enabled := False
		ensure
			set: not is_multiple_selection_enabled
		end

	enable_multiple_selection
			-- Set `is_multiple_selection_enabled' to True.
		do
			is_multiple_selection_enabled := True
		ensure
			set: is_multiple_selection_enabled
		end

feature -- List change

	wipe_out
			-- <Precursor>
		do
			Precursor {EV_MODEL_WORLD}
			across
				nodes as it
			loop
				it.item.recycle
			end

			across
				links as it
			loop
				it.item.recycle
			end

			across
				clusters as it
			loop
				it.item.recycle
			end

			nodes.wipe_out
			clusters.wipe_out
			links.wipe_out
			selected_figures.wipe_out
			root_cluster.wipe_out
		end

feature -- Element change

	recycle
			-- Free `Current's resources and leave it in an unstable state.
		do
			wipe_out

			pointer_button_press_actions.prune_all (agent on_pointer_button_press_on_world)
			pointer_button_release_actions.prune_all (agent on_pointer_button_release_on_world)
			pointer_motion_actions.prune_all (agent on_pointer_motion_on_world)

			model.node_add_actions.prune_all (agent add_node)
			model.link_add_actions.prune_all (agent add_link)
			model.cluster_add_actions.prune_all (agent add_cluster)

			model.link_remove_actions.prune_all (agent remove_link)
			model.node_remove_actions.prune_all (agent remove_node)
			model.cluster_remove_actions.prune_all (agent remove_cluster)
		end


	set_factory (a_factory: like factory)
			-- Set `factory' to `a_factory'.
		obsolete
			"Use `make_with_model_and_factory' instead; [04-2014]"
		require
			a_factory_not_Void: a_factory /= Void
		do
			factory := a_factory
			a_factory.set_world (Current)
		ensure
			set: factory = a_factory
		end

	select_displayed_nodes
			-- Select all displayed nodes on the diagram.
		local
			l_item: EG_LINKABLE_FIGURE
		do
			across
				nodes as it
			loop
				l_item := it.item
				if l_item.is_show_requested and not selected_figures.has (l_item) then
					selected_figures.extend (l_item)
					set_figure_selection_state (l_item, True)
				end
			end
		end

	deselect_all
			-- Deselect all Figures.
		do
			across
				selected_figures as it
			loop
				set_figure_selection_state (it.item, False)
			end
			selected_figures.wipe_out
		ensure
			selected_figures_is_empty: selected_figures.is_empty
		end

	add_node (a_node: like node_type)
			-- `a_node' was added to the model.
		require
			a_node_not_void: a_node /= Void
			model_has_node: model.has_node (a_node)
			not_has_a_node: not has_linkable_figure (a_node)
		local
			node_figure: EG_LINKABLE_FIGURE
		do
			node_figure := factory.new_node_figure (a_node)
			extend (node_figure)
			root_cluster.extend (node_figure)
			nodes.extend (node_figure)
			linkable_add (node_figure)

			linkables_to_figures.put (node_figure, a_node)
			figure_added (node_figure)
		ensure
			has_node_figure: has_linkable_figure (a_node)
		end

	add_link (a_link: EG_LINK)
			-- `a_link' was added to the model.
		require
			a_link_not_void: a_link /= Void
			model_has_link: model.has_link (a_link)
			not_has_a_link: not has_link_figure (a_link)
			has_source_figure: has_linkable_figure (a_link.source)
			has_target_figure: has_linkable_figure (a_link.target)
		local
			link_figure: EG_LINK_FIGURE
		do
			if
				attached linkables_to_figures.item (a_link.source) as l_source and
				attached linkables_to_figures.item (a_link.target) as l_target
			then
				link_figure := factory.new_link_figure (a_link, l_source, l_target)
				put_front (link_figure)
				links.extend (link_figure)

				l_source.add_link (link_figure)
				l_target.add_link (link_figure)

				links_to_figures.put (link_figure, a_link)
				figure_added (link_figure)
			else
					-- Per precondition `has_source_figure' and `has_target_figure'
				check
					has_source_and_target_figures: False
				end
			end
		ensure
			has_a_link: has_link_figure (a_link)
		end

	add_cluster (a_cluster: EG_CLUSTER)
			-- `a_cluster' was added to the model.
		require
			a_cluster_not_void: a_cluster /= Void
			model_has_cluster: model.has_cluster (a_cluster)
			not_has_a_cluster: not has_cluster_figure (a_cluster)
			a_cluster.flat_linkables.for_all (agent has_linkable_figure)
		local
			cluster_figure: EG_CLUSTER_FIGURE
		do
			cluster_figure := factory.new_cluster_figure (a_cluster)
			extend (cluster_figure)
			root_cluster.extend (cluster_figure)
			linkable_add (cluster_figure)
			clusters.extend (cluster_figure)

			across
				a_cluster.linkables as it
			loop
				cluster_figure.model.linkable_add_actions.call ([it.item])
			end

			cluster_figure.request_update

			linkables_to_figures.put (cluster_figure, a_cluster)
			figure_added (cluster_figure)
		ensure
			has_cluster: has_cluster_figure (a_cluster)
		end

	remove_link (a_link: EG_LINK)
			-- Remove `a_link' from view.
		require
			a_link_not_void: a_link /= Void
		do
			if attached links_to_figures.item (a_link) as link_figure then
				link_figure.source.remove_link (link_figure)
				link_figure.target.remove_link (link_figure)
				if attached link_figure.group as l_group then
					l_group.prune_all (link_figure)
				end
				links.prune_all (link_figure)
				links_to_figures.remove (a_link)
				if selected_figures.has (link_figure) then
					selected_figures.start
					selected_figures.search (link_figure)
					selected_figures.remove
					set_figure_selection_state (link_figure, False)
				end
				figure_removed (link_figure)
			end
		ensure
			not_has_a_link: not has_link_figure (a_link)
			selected_figures_in_world: selected_figures_in_world
		end

	remove_node (a_node: like node_type)
			-- Remove `a_node' from view and all its links.
		require
			a_node_not_void: a_node /= Void
		do
			if attached linkables_to_figures.item (a_node) as node_figure then
				if attached node_figure.cluster as l_cluster then
					l_cluster.prune_all (node_figure)
				else
					root_cluster.prune_all (node_figure)
				end

				across
					a_node.links.twin as it
				loop
					remove_link (it.item)
				end
				prune_all (node_figure)
				nodes.prune_all (node_figure)
				linkables_to_figures.remove (a_node)
				if selected_figures.has (node_figure) then
					selected_figures.start
					selected_figures.search (node_figure)
					selected_figures.remove
					set_figure_selection_state (node_figure, False)
				end
				figure_removed (node_figure)
			end
		ensure
			not_has_a_node: not has_linkable_figure (a_node)
			selected_figures_in_world: selected_figures_in_world
		end

	remove_cluster (a_cluster: EG_CLUSTER)
			-- Remove `a_cluster' from view and elements in it and all links.
		require
			a_cluster_not_void: a_cluster /= Void
		local
			l_item: EG_LINKABLE
		do
			if attached {EG_CLUSTER_FIGURE} linkables_to_figures.item (a_cluster) as cluster_figure then
				across
					a_cluster.linkables.twin as it
				loop
					l_item := it.item
					if attached {EG_CLUSTER} l_item as l_cluster then
						remove_cluster (l_cluster)
					elseif attached {like node_type} l_item as l_node then
						remove_node (l_node)
					end
				end
				if attached cluster_figure.cluster as l_cluster_2 then
					l_cluster_2.prune_all (cluster_figure)
				else
					root_cluster.prune_all (cluster_figure)
				end

				across
					a_cluster.links.twin as it
				loop
					remove_link (it.item)
				end
				prune_all (cluster_figure)
				clusters.prune_all (cluster_figure)
				linkables_to_figures.remove (a_cluster)
				if selected_figures.has (cluster_figure) then
					selected_figures.start
					selected_figures.search (cluster_figure)
					selected_figures.remove
					set_figure_selection_state (cluster_figure, False)
				end
				figure_removed (cluster_figure)
			end
		ensure
			not_has_cluster: not has_cluster_figure (a_cluster)
			selected_figures_in_world: selected_figures_in_world
		end

	update
			-- Update all figures with `is_update_required' in `Current'.
		local
			l_item: EG_FIGURE
			l_link: EG_LINK_FIGURE
		do
			across
				root_cluster as it
			loop
				l_item := it.item
				if attached {EG_CLUSTER_FIGURE} l_item as l_cluster and then l_cluster.is_update_required then
					update_cluster (l_cluster)
				end
				if l_item.is_update_required then
					l_item.update
				end
			end

			across
				links as it
			loop
				l_link := it.item
				if l_link.is_update_required then
					l_link.update
				end
			end
		end

	scale (a_scale: REAL_64)
			-- <Precursor>
		local
			l_scale: REAL
		do
			l_scale := a_scale.truncated_to_real
			Precursor {EV_MODEL_WORLD} (a_scale)
			scale_factor := scale_factor * a_scale
			real_grid_x := real_grid_x * l_scale
			if grid_x /= as_integer (real_grid_x) then
				grid_x := as_integer (real_grid_x)
			end
			real_grid_y := real_grid_y * l_scale
			if grid_y /= as_integer (real_grid_y) then
				grid_y := as_integer (real_grid_y)
			end
		ensure then
			new_scale_factor: scale_factor = old scale_factor * a_scale
		end

feature -- Visitor

	process (v: EG_FIGURE_VISITOR)
			-- <Precursor>
		do
			v.process_figure_world (Current)
		end

feature -- Save/Restore

	store (ptf: RAW_FILE)
			-- Freeze state of `Current'.
		require
			ptf_not_Void: ptf /= Void
		local
			diagram_output: XML_DOCUMENT
			root: like xml_element
		do
			create diagram_output.make_with_root_named (xml_node_name, create {XML_NAMESPACE}.make_default)

			create root.make_root (create {XML_DOCUMENT}.make, "VIEW", xml_namespace)
			diagram_output.root_element.force_first (xml_element (root))
			Xml_routines.save_xml_document_with_path (ptf.path, diagram_output)
		end

	retrieve (f: RAW_FILE)
			-- Reload former state of `Current'.
		require
			f_not_Void: f /= Void
		do
			if
				attached Xml_routines.deserialize_document_with_path (f.path) as l_diagram_input
			then
				check
					valid_xml: l_diagram_input.root_element.has_same_name (xml_node_name)
				end
				if attached {like xml_element} l_diagram_input.root_element.first as view_input then
					xml_routines.valid_tags_read
					view_input.start
					set_with_xml_element (view_input)
				end
			end
		end

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := "EG_FIGURE_WORLD"
		end

	xml_element (node: like xml_element): XML_ELEMENT
			-- <Precursor>
		local
			fig: like xml_element
			l_item: EG_FIGURE
			root_elements: like xml_element
		do
			node.put_last (Xml_routines.xml_node (node, "SCALE_FACTOR", scale_factor.out))

			create root_elements.make (node, "ROOT_ELEMENTS", xml_namespace)
			across
				root_cluster as it
			loop
				l_item := it.item
				if l_item.is_storable then
					create fig.make (root_elements, l_item.xml_node_name, xml_namespace)
					root_elements.put_last (l_item.xml_element (fig))
				end
			end

			across
				links as it
			loop
				l_item := it.item
				if l_item.is_storable then
					create fig.make (root_elements, l_item.xml_node_name, xml_namespace)
					root_elements.put_last (l_item.xml_element (fig))
				end
			end
			node.put_last (root_elements)

			Result := node
		end

	set_with_xml_element (a_node: like xml_element)
			-- <Precursor>
		local
			sf: REAL_64
			l_node: EG_LINKABLE_FIGURE
			l_link: EG_LINK_FIGURE
			l_cluster: EG_LINKABLE_FIGURE
		do
			sf := xml_routines.xml_double (a_node, "SCALE_FACTOR")
			if sf = 0.0 then
				sf := 1.0
			end
			scale (sf / scale_factor)
			if attached {like xml_element} a_node.item_for_iteration as l_xml_element then
				a_node.forth
				across
					l_xml_element as it
				loop
					if
						attached {like xml_element} it.item as l_item
						and then attached {EG_ITEM} factory.model_from_xml (l_item) as eg_item
					then
						if attached {EG_CLUSTER} eg_item as eg_cluster then
							if not model.has_cluster (eg_cluster) then
								model.add_cluster (eg_cluster)
							end
						elseif attached {EG_NODE} eg_item as eg_node then
							if not model.has_node (eg_node) then
								model.add_node (eg_node)
							end
						elseif attached {EG_LINK} eg_item as eg_link then
							if not model.has_link (eg_link) then
								model.add_link (eg_link)
							end
						else
							check
								is_cluster_link_or_node: False
							end
						end
						if attached figure_from_model (eg_item) as eg_fig then
							l_item.start
							eg_fig.set_with_xml_element (l_item)
						else
							check
								figure_inserted: False
							end
						end
					end
				end
				across
					nodes as it
				loop
					l_node := it.item
					if l_node.is_selected then
						selected_figures.extend (l_node)
					end
				end
				across
					links as it
				loop
					l_link := it.item
					if l_link.is_selected then
						selected_figures.extend (l_link)
					end
				end
				across
					clusters as it
				loop
					l_cluster := it.item
					if l_cluster.is_selected then
						selected_figures.extend (l_cluster)
					end
				end
			end
		end

feature {EG_FIGURE, EG_LAYOUT, EG_FIGURE_VISITOR} -- Implementation

	items_to_figure_lookup_table: HASH_TABLE [EG_FIGURE, EG_ITEM]
			-- The table maps EG_ITEM objects to EG_FIGURE objects (model to view).
		obsolete
			"Use `linkables_to_figures' and `links_to_figures' instaed; [04-2014]"
		do
			create Result.make (linkables_to_figures.count + links_to_figures.count)
			across
				linkables_to_figures as it
			loop
				Result.put (it.item, it.key)
			end
			across
				links_to_figures as it
			loop
				Result.put (it.item, it.key)
			end
		end

	linkables_to_figures: HASH_TABLE [EG_LINKABLE_FIGURE, EG_LINKABLE]
			-- Mapping of linkable model to linkable view.

	links_to_figures: HASH_TABLE [EG_LINK_FIGURE, EG_LINK]
			-- Mapping of link model to link view.

	root_cluster: ARRAYED_LIST [EG_LINKABLE_FIGURE]
			-- All linkables not beeing part of a cluster.

	nodes: ARRAYED_LIST [EG_LINKABLE_FIGURE]
			-- All nodes in `Current'

	clusters: ARRAYED_LIST [EG_CLUSTER_FIGURE]
			-- All clusters in `Current'

	links: ARRAYED_LIST [EG_LINK_FIGURE]
			-- All links in `Current'

feature {NONE} -- Implementation

	real_grid_x: REAL
			-- Real grid width in x direction.

	real_grid_y: REAL
			-- Real grid width in y direction.

	insert_cluster (a_cluster: EG_CLUSTER)
			-- Insert `a_cluster' to view and all its containing subclusters (recursive).
		require
			a_cluster_not_void: a_cluster /= Void
			not_has_cluster: not has_cluster_figure (a_cluster)
			non_linkable_already_part_of_view: not a_cluster.flat_linkables.there_exists (agent has_linkable_figure)
		do
			across
				a_cluster.linkables as it
			loop
				if attached {EG_CLUSTER} it.item as l_cur_cluster then
					insert_cluster (l_cur_cluster)
				elseif attached {like node_type} it.item as l_cur_node then
					add_node (l_cur_node)
				else
					check invalid_node: False end
				end
			end
			add_cluster (a_cluster)
		ensure
			has_cluster: has_cluster_figure (a_cluster)
			all_linkables_part_of_view: a_cluster.flat_linkables.for_all (agent has_linkable_figure)
		end

	linkable_add (a_linkable: EG_LINKABLE_FIGURE)
			-- `a_linkable' was added to `Current'.
		require
			a_linkable_not_void: a_linkable /= Void
		do
			a_linkable.pointer_button_press_actions.extend (agent on_pointer_button_press (a_linkable, ?, ?, ?, ?, ?, ?, ?, ?))
			a_linkable.move_actions.extend (agent on_linkable_move (a_linkable, ?, ?, ?, ?, ?, ?, ?))
		end

	selected_figure: detachable EV_MODEL
			-- The figure the user clicked on. (Void if none).

	on_pointer_button_press (figure: EG_LINKABLE_FIGURE; ax, ay, button: INTEGER; x_tilt, y_tilt, pressure: REAL_64; screen_x, screen_y: INTEGER)
			-- Pointer button was pressed on `figure'.
		require
			figure_not_void: figure /= Void
		do
			if attached figure.cluster as l_cluster then
				l_cluster.bring_to_front (figure)
			else
				bring_to_front (figure)
			end
			if not attached {EG_CLUSTER_FIGURE} figure then
				if not ev_application.ctrl_pressed and then not selected_figures.has (figure) then
					deselect_all
				end
				if not figure_was_selected and then button = 1 then --and then not ev_application.ctrl_pressed then
					if figure.is_selected and then ev_application.ctrl_pressed then
						selected_figures.prune_all (figure)
						set_figure_selection_state (figure, False)
					elseif not selected_figures.has (figure) then
						selected_figures.extend (figure)
						set_figure_selection_state (figure, True)
					end
					figure_was_selected := True
				end
			elseif not ev_application.ctrl_pressed and then not figure_was_selected and then button = 1 then
				deselect_all
			end
			selected_figure := figure
		end

	set_figure_selection_state (a_figure: EG_FIGURE; a_selection_state: BOOLEAN)
			-- Set `is_selected' state of `a_figure' to `a_selection_state'.
		do
			if a_selection_state then
				a_figure.enable_selected
			else
				a_figure.disable_selected
			end
		end

	on_linkable_move (figure: EG_LINKABLE_FIGURE; ax, ay: INTEGER; x_tilt, y_tilt, pressure: REAL_64; screen_x, screen_y: INTEGER)
			-- `figure' was moved for `ax' `ay'.
			-- | Move all `selected_figures' as well.
		require
			figure_not_void: figure /= Void
		local
			l_item: EG_FIGURE
		do
			if not attached {EG_CLUSTER_FIGURE} figure and not selected_figures.is_empty then
				check
					when_figures_selected_move_only_a_selected_figure: selected_figures.has (figure)
				end

				across
					selected_figures as it
				loop
					l_item := it.item
					if l_item /= figure then
						l_item.set_point_position (l_item.point_x + ax, l_item.point_y + ay)
						if attached {EG_LINKABLE_FIGURE} l_item as l_linkable then
							l_linkable.set_is_fixed (True)
						end
					end
				end
			end
		end

	figure_was_selected: BOOLEAN
			-- Was a figure allready selected?

	is_figure_moved: BOOLEAN
			-- Is a figure moved?

	on_pointer_button_press_on_world (ax, ay, button: INTEGER; x_tilt, y_tilt, pressure: REAL_64; screen_x, screen_y: INTEGER)
			-- Pointer button was pressed somewhere in the world.
			-- | Used for starting multiple selection.
		local
			l_rect: attached like multi_select_rectangle
		do
			if button = 1 then
				if
					not figure_was_selected and
					ev_application.ctrl_pressed and
					attached multi_select_rectangle as al_rect
				then
					prune_all (al_rect)
					create l_rect.make_with_positions (ax, ay, ax, ay)
					multi_select_rectangle := l_rect
					l_rect.enable_dashed_line_style
					extend (l_rect)
					selected_figure := multi_select_rectangle
					enable_capture
				elseif selected_figure /= Void then
					is_figure_moved := True
					figure_change_start_actions.call (Void)
				else
					-- If there is a selection and we click in a blank area
					-- then deselect all figures.
					deselect_all
				end
			end
			figure_was_selected := False
		end

	on_pointer_motion_on_world (ax, ay: INTEGER; x_tilt, y_tilt, pressure: REAL_64; screen_x, screen_y: INTEGER)
			-- Pointer was moved in world.
		local
			l_bbox, l_tmp_bbox: EV_RECTANGLE
			l_item: EG_LINKABLE_FIGURE
		do
			if attached multi_select_rectangle as l_rect then
				l_rect.set_point_b_position (ax, ay)
				l_bbox := l_rect.bounding_box
				create l_tmp_bbox
				if not ev_application.ctrl_pressed then
					deselect_all
				end
				across
					nodes as it
				loop
					l_item := it.item
					if l_item.is_show_requested then
						l_item.update_rectangle_to_bounding_box (l_tmp_bbox)
						if
							l_tmp_bbox.intersects (l_bbox) and
							not l_item.is_selected
						then
							selected_figures.extend (l_item)
							set_figure_selection_state (it.item, True)
							figure_was_selected := True
						end
					end
				end
			end
		end

	on_pointer_button_release_on_world (ax, ay, button: INTEGER; x_tilt, y_tilt, pressure: REAL_64; screen_x, screen_y: INTEGER)
			-- Pointer was released over world.
		do
			if attached multi_select_rectangle as l_rect then
				prune_all (l_rect)
				full_redraw
				multi_select_rectangle := Void
				disable_capture
			end
			if is_figure_moved then
				figure_change_end_actions.call (Void)
				is_figure_moved := False
			end
			selected_figure := Void
		end

	multi_select_rectangle: detachable EV_MODEL_RECTANGLE
			-- Rectangle used to multiselect nodes.

	figure_added (a_figure: EG_FIGURE)
			-- `a_figure' was added to the world. Redefine this to do your
			-- own initialisation.
		require
			a_figure_not_void: a_figure /= Void
		do
			if scale_factor /= 1.0 then
				a_figure.scale (scale_factor)
				a_figure.request_update
			end
		ensure
			links_to_figures_unchanged: links_to_figures ~ old links_to_figures
			linkables_to_figures_unchanged: linkables_to_figures ~ old linkables_to_figures
		end

	figure_removed (a_figure: EG_FIGURE)
			-- `a_figure' was removed from the world.
		require
			a_figure_not_Void: a_figure /= Void
		do
			a_figure.recycle
		end

	update_cluster (a_cluster: EG_CLUSTER_FIGURE)
			-- Update all figures with `is_update_required' in `cluster'.
		require
			cluster_not_void: a_cluster /= Void
		local
			i: INTEGER
		do
			from
				i := a_cluster.count
			until
				i < 1
			loop
				if attached {EG_FIGURE} a_cluster [i] as l_fig then
					if attached {EG_CLUSTER_FIGURE} l_fig as l_cluster and then l_cluster.is_update_required then
						update_cluster (l_cluster)
					end
					if l_fig.is_update_required then
						l_fig.update
					end
				end
				i := i - 1
			end
		end

feature {NONE} -- Anchor

	node_type: EG_NODE
			-- Type for nodes.
		require
			callable: False
		do
			check callable: False then end
		end

feature {NONE} -- Obsolete

	new_filled_list (n: INTEGER): like Current
			-- <Precursor>
		do
			check not_implemented: False then end
		end

invariant
	model_not_void: model /= Void
	factory_not_void: factory /= Void
	links_to_figure_not_void: links_to_figures /= Void
	linkables_to_figure_not_void: linkables_to_figures /= Void
	root_cluster_not_void: root_cluster /= Void
	clusters_not_void: clusters /= Void
	nodes_not_void: nodes /= Void
	links_not_void: links /= Void

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




end -- class EG_FIGURE_WORLD

