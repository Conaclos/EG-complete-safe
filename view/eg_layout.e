note
	description: "Objects that can layout nodes and clusters in a given world."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_LAYOUT

feature {NONE} -- Initialization

	make_with_world (a_world: like world)
			-- Make.
		require
			a_world /= Void
		do
			default_create
			world := a_world
		ensure
			set: world = a_world
		end

feature -- Access

	world: EG_FIGURE_WORLD
			-- The graph to layout.

feature -- Element change

	set_world (a_world: like world)
			-- Set `world' to `a_world'.
		require
			a_world_not_void: a_world /= Void
		do
			world := a_world
		ensure
			set: world = a_world
		end

	layout
			-- Arrange the elements in `graph'.
		do
			world.update
			across
				world.root_cluster as it
			loop
				if attached {EG_CLUSTER_FIGURE} it.item as cluster_figure then
					if attached cluster_figure.layouter as l_layouter then
						l_layouter.layout_cluster (cluster_figure, 2)
					else
						layout_cluster (cluster_figure, 2)
					end
				end
			end
			layout_linkables (world.root_cluster, 1, void)
		end

	layout_cluster (cluster: EG_CLUSTER_FIGURE; level: INTEGER)
			-- Arrange the elements in `cluster' (recursive).
		require
			cluster_not_void: cluster /= Void
			level_greater_zero: level > 0
		local
			figures_in_cluster: ARRAYED_LIST [EG_LINKABLE_FIGURE]
		do
			create figures_in_cluster.make (cluster.count)
			across
				cluster as it
			loop
				if attached {EG_LINKABLE_FIGURE} it.item as linkable_figure then
					figures_in_cluster.extend (linkable_figure)
					if attached {EG_CLUSTER_FIGURE} linkable_figure as cluster_figure then
						if attached cluster_figure.layouter as l_layouter then
							l_layouter.layout_cluster (cluster_figure, level + 1)
						else
							layout_cluster (cluster_figure, level + 1)
						end
					end
				end
			end
			layout_linkables (figures_in_cluster, level, cluster)
		end

	layout_cluster_only (cluster: EG_CLUSTER_FIGURE)
			-- Arrange the elements in `cluster' (not recursive).
		require
			cluster_not_void: cluster /= Void
		local
			figures_in_cluster: ARRAYED_LIST [EG_LINKABLE_FIGURE]
		do
			create figures_in_cluster.make (cluster.count)
			across
				cluster as it
			loop
				if attached {EG_LINKABLE_FIGURE} it.item as linkable_figure then
					figures_in_cluster.extend (linkable_figure)
				end
			end
			layout_linkables (figures_in_cluster, 1, cluster)
		end

feature {NONE} -- Implementation

	layout_linkables (a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]; a_level: INTEGER; a_cluster: detachable EG_CLUSTER_FIGURE)
			-- arrange `linkables' that are elements of `clusters' at `level'.
		require
			linkables_not_void: a_linkables /= Void
			level_greater_zero: a_level > 0
			level_greater_1_implies_cluster_not_void: a_level > 1 implies a_cluster /= Void
		deferred
		end

invariant
	world_not_void: world /= Void

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




end -- class EG_LAYOUT

