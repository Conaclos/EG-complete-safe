note
	description: "[
			In a EG_QUAD_TREE a `region' is splited into fore equaly sized parts:

						nw|ne
						--+--
						sw|se

			If the the tree has no childrens, meaning it is a leaf, then `particle' is element
			of `region' otherwise the particles in the childrens are element of the childrens
			regions.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_QUAD_TREE

create
	make

feature {NONE} -- Initialization

	make (a_region: like region; a_particle: attached like particle)
			-- Make a node with `region' `a_region' containing a_particle.
		require
			a_region_exists: a_region /= Void
			a_particle_exists: a_particle /= Void
		do
			region := a_region
			particle := a_particle
			is_leaf := True
		ensure
			set: region = a_region and particle = a_particle
			is_leaf: is_leaf
		end

feature -- Status report

	is_leaf: BOOLEAN
			-- Is node a leaf?

	valid_tree: BOOLEAN
			-- Are all particles in `Current' element `region'?
		do
			if attached particle as l_particle then
				check
					is_leaf: is_leaf
				end
				Result := region.has_x_y (l_particle.x, l_particle.y)
			else
				Result := childe_sw /= Void and then childe_sw.valid_tree or
					childe_se /= Void and then childe_se.valid_tree or
					childe_nw /= Void and then childe_nw.valid_tree or
					childe_ne /= Void and then childe_ne.valid_tree
			end
		end

feature -- Access

	region: EV_RECTANGLE
			-- All particles element of `Current' Tree are element of `region'.

	particle: detachable EG_PARTICLE
			-- Particle in the node.

	childe_sw: detachable EG_QUAD_TREE
			-- Root node for particles in the south west part of `region'.
		note
			option: stable
		attribute end

	childe_se: detachable EG_QUAD_TREE
			-- Root node for particles in the south east part of `region'.
		note
			option: stable
		attribute end

	childe_ne: detachable EG_QUAD_TREE
			-- Root node for particles in the north east part of `region'.
		note
			option: stable
		attribute end

	childe_nw: detachable EG_QUAD_TREE
			-- Root node for particles int the north west part of `region'.
		note
			option: stable
		attribute end

	center_of_mass_particle: EG_PARTICLE
			-- The average particle of all the children particles or particle if `is_leaf'.
			-- The result is cached for next use.
		local
			x, y: REAL_64
			l_cmp: like center_of_mass_particle
			mass, l_mass: REAL_64
		do
			if attached center_of_mass_particle_cache as l_cache then
				Result := l_cache
			else
				if attached particle as l_particle then
					Result := l_particle
				else
					if childe_sw /= Void then
						l_cmp := childe_sw.center_of_mass_particle
						mass := l_cmp.mass
						x := l_cmp.x * mass
						y := l_cmp.y * mass
					end
					if childe_se /= Void then
						l_cmp := childe_se.center_of_mass_particle
						l_mass := l_cmp.mass
						x := x + l_cmp.x * l_mass
						y := y + l_cmp.y * l_mass
						mass := l_mass + mass
					end
					if childe_ne /= Void then
						l_cmp := childe_ne.center_of_mass_particle
						l_mass := l_cmp.mass
						x := x + l_cmp.x * l_mass
						y := y + l_cmp.y * l_mass
						mass := l_mass + mass
					end
					if childe_nw /= Void then
						l_cmp := childe_nw.center_of_mass_particle
						l_mass := l_cmp.mass
						x := x + l_cmp.x * l_mass
						y := y + l_cmp.y * l_mass
						mass := l_mass + mass
					end
					create Result.make ((x / mass).truncated_to_integer, (y / mass).truncated_to_integer, mass)
				end
				center_of_mass_particle_cache := Result
			end
		ensure
			cached_result: center_of_mass_particle_cache = Result
			inside: region.has_x_y (Result.x, Result.y)
		end

feature -- Element change

	reset_center_of_mass
			-- Remove the cached value for `center_of_mass_particle'
		do
			center_of_mass_particle_cache := Void
		ensure
			set: center_of_mass_particle_cache = Void
		end

	build_center_of_mass
			-- Build a center of mass for every node in the tree.
		obsolete
			"Use `reset_center_of_mass' instead. [04-2014]"
		do
			reset_center_of_mass
			center_of_mass_particle_cache := center_of_mass_particle
		ensure
			cached_result: center_of_mass_particle_cache /= Void
		end

	insert (a_particle: attached like particle)
			-- Insert `a_particle' into the right position in the tree.
			-- Reset `center_of_mass_particle'.
		require
			a_particle_exists: a_particle /= Void
			a_particle_in_region: region.has_x_y (a_particle.x, a_particle.y)
			not_has_a_particle: not has (a_particle)
		local
			hh, hw: INTEGER
			px, py: INTEGER
		do
			hw := (region.width / 2).ceiling
			hh := (region.height / 2).ceiling
			if attached particle as l_particle then
					-- It's a leaf push down particle.
				px := l_particle.x
				py := l_particle.y
				if px >= region.left + hw then
					if py >= region.top + hh then
						create childe_se.make (create {EV_RECTANGLE}.set (region.left + hw, region.top + hh, hw, hh), l_particle)
					else
						create childe_ne.make (create {EV_RECTANGLE}.set (region.left + hw, region.top, hw, hh), l_particle)
					end
				else
					if py >= region.top + hh then
						create childe_sw.make (create {EV_RECTANGLE}.set (region.left, region.top + hh, hw, hh), l_particle)
					else
						create childe_nw.make (create {EV_RECTANGLE}.set (region.left, region.top, hw, hh), l_particle)
					end
				end
					-- Ensure invariant.
				particle := Void
			end
			check
				particle_pushed_down: particle = Void
			end
			px := a_particle.x
			py := a_particle.y
			if px >= region.left + hw then
				if py >= region.top + hh then
					if childe_se /= Void then
						childe_se.insert (a_particle)
					else
						create childe_se.make (create {EV_RECTANGLE}.set (region.left + hw, region.top + hh, hw, hh), a_particle)
					end
				else
					if childe_ne /= Void then
						childe_ne.insert (a_particle)
					else
						create childe_ne.make (create {EV_RECTANGLE}.set (region.left + hw, region.top, hw, hh), a_particle)
					end
				end
			else
				if py >= region.top + hh then
					if childe_sw /= Void then
						childe_sw.insert (a_particle)
					else
						create childe_sw.make (create {EV_RECTANGLE}.set (region.left, region.top + hh, hw, hh), a_particle)
					end
				else
					if childe_nw /= Void then
						childe_nw.insert (a_particle)
					else
						create childe_nw.make (create {EV_RECTANGLE}.set (region.left, region.top, hw, hh), a_particle)
					end
				end
			end
			is_leaf := False
			reset_center_of_mass
		ensure
			inserted: has (a_particle)
		end

	has (a_particle: EG_PARTICLE): BOOLEAN
			-- Is a particle equal to `a_particle' element of `Current' tree?
		require
			a_particle_not_void: a_particle /= Void
		local
			px, py: INTEGER
			hh, hw: INTEGER
		do
			px := a_particle.x
			py := a_particle.y
			if region.has_x_y (px, py) then
				if attached particle as l_particle then
						-- Reached the leaf.
					Result := l_particle.x = px and l_particle.y = py
				else
					hw := (region.width / 2).ceiling
					hh := (region.height / 2).ceiling
						-- Look into childrens.
					if px >= region.left + hw then
						if py >= region.top + hh then
							Result := childe_se /= Void and then childe_se.has (a_particle)
						else
							Result := childe_ne /= Void and then childe_ne.has (a_particle)
						end
					else
						if py >= region.top + hh then
							Result := childe_sw /= Void and then childe_sw.has (a_particle)
						else
							Result := childe_nw /= Void and then childe_nw.has (a_particle)
						end
					end
				end
			end
		end

feature {NONE} -- Implementation

	center_of_mass_particle_cache: detachable like center_of_mass_particle
		-- Cache storage for `center_of_mass_particle'.

invariant
	leaf_has_particle_inner_nodes_do_not: is_leaf = (particle /= Void)
	leaf_has_no_childe: is_leaf = (childe_sw = Void and childe_se = Void and childe_ne = Void and childe_nw = Void)
	is_leaf_implies_has_particle: is_leaf implies (attached particle as l_particle and then region.has_x_y (l_particle.x, l_particle.y))

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




end -- class EG_QUAD_TREE

