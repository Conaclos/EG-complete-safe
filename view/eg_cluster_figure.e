note
	description: "Object is a view for an EG_CLUSTER."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_CLUSTER_FIGURE

inherit
	EG_LINKABLE_FIGURE
		redefine
			model,
			initialize,
			set_is_fixed,
			xml_node_name,
			xml_element,
			set_with_xml_element,
			recycle,
			process
		end

feature {NONE} -- Initialization

	initialize
			-- <Precursor>
		do
			Precursor {EG_LINKABLE_FIGURE}
			model.linkable_add_actions.extend (agent on_linkable_add)
			model.linkable_remove_actions.extend (agent on_linkable_remove)
		end

feature -- Access

	model: EG_CLUSTER
			-- <Precursor>

	layouter: detachable EG_LAYOUT assign set_layouter
			-- Layouter used for this `Cluster' if not Void.

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := once "EG_CLUSTER_FIGURE"
		end

	subclusters: ARRAYED_LIST [EG_CLUSTER_FIGURE]
			-- Clusters with parent `Current'.
		do
			create {ARRAYED_LIST [EG_CLUSTER_FIGURE]} Result.make (1)
			across
				Current as it
			loop
				if attached {EG_CLUSTER_FIGURE} it.item as l_cluster_figure then
					Result.extend (l_cluster_figure)
				end
			end
		ensure
			Result_not_void: Result /= Void
		end

	xml_element (a_node: like xml_element): XML_ELEMENT
			-- <Precursor>
		local
			l_figure, l_elements: like xml_element
		do
			Result := Precursor {EG_LINKABLE_FIGURE} (a_node)
			create l_elements.make (a_node, once "ELEMENTS", xml_namespace)
			across
				Current as it
			loop
				if attached {EG_LINKABLE_FIGURE} it.item as eg_fig then
					create l_figure.make (l_elements, eg_fig.xml_node_name, xml_namespace)
					l_elements.put_last (eg_fig.xml_element (l_figure))
				end
			end
			Result.put_last (l_elements)
		end

	set_with_xml_element (a_node: like xml_element)
			-- <Precursor>
		do
			Precursor {EG_LINKABLE_FIGURE} (a_node)
			if
				attached {XML_ELEMENT} a_node.item_for_iteration as l_elements
				and then attached world as l_world
				and then attached l_world.model as l_world_model
			then
				a_node.forth
				across
					l_elements as it
				loop
					if
						attached {like xml_element} it.item as l_item
						and then attached {EG_LINKABLE} l_world.factory.model_from_xml (l_item) as eg_model
					then
						if not l_world_model.has_linkable (eg_model) then
							if attached {EG_CLUSTER} eg_model as eg_cluster then
								l_world_model.add_cluster (eg_cluster)
							elseif attached {EG_NODE} eg_model as eg_node then
								l_world_model.add_node (eg_node)
							else
								check node_or_cluster: False end
							end
						end
						if not model.has (eg_model) then
							model.extend (eg_model)
						end
						if attached l_world.figure_from_model (eg_model) as l_fig then
							l_item.start
							l_fig.set_with_xml_element (l_item)
						end
					end
				end
			end
		end

feature -- Element change

	recycle
			-- <Precursor>
		do
			Precursor {EG_LINKABLE_FIGURE}
			model.linkable_add_actions.prune_all (agent on_linkable_add)
			model.linkable_remove_actions.prune_all (agent on_linkable_remove)
		end

	set_layouter (a_layouter: like layouter)
			-- Set `layouter' to `a_layouter'.
		do
			layouter := a_layouter
		ensure
			set: layouter = a_layouter
		end

feature -- Status settings

	set_is_fixed (b: BOOLEAN)
			-- <Precursor>
		do
			Precursor {EG_LINKABLE_FIGURE} (b)
			across
				Current as it
			loop
				if attached {EG_LINKABLE_FIGURE} it.item as l_linkable_figure then
					l_linkable_figure.set_is_fixed (b)
				end
			end
		end

feature -- Visitor

	process (v: EG_FIGURE_VISITOR)
			-- <Precursor>
		do
			v.process_cluster_figure (Current)
		end

feature {NONE} -- Implementation

	on_linkable_add (a_linkable: EG_LINKABLE)
			-- `a_linkable' was added to the cluster.
		do
			if
				attached world as l_world and then
				attached l_world.linkables_to_figures.item (a_linkable) as l_linkable_fig
			then
				check
					linkable_fig_is_in_view_but_not_in_cluster: not has (l_linkable_fig)
				end
				extend (l_linkable_fig)
				l_linkable_fig.set_cluster (Current)
			end
			request_update
		end

	on_linkable_remove (a_linkable: EG_LINKABLE)
			-- `a_linkable' was removed from the cluster.
		do
			if
				attached world as l_world and then
				attached l_world.linkables_to_figures.item (a_linkable) as l_linkable_fig
			then
				l_linkable_fig.set_cluster (Void)
				prune_all (l_linkable_fig)
			end
			request_update
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




end -- class EG_CLUSTER_FIGURE

