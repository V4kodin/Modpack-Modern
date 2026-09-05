// priority: 0
"use strict";

/**
 * GregTech only tags the bucket item of a material fluid, so the fluid itself
 * stays untagged and cannot be picked in fluid filters (EMI search, AE2 export
 * bus, GT tag filters). Mirror the material name onto its fluid, and give the
 * slurries umbrella tags so a whole stage can be filtered at once.
 *
 * Only opt-in materials are covered: a blanket mirror would pour GregTech
 * fluids into shared vanilla/Forge tags such as forge:milk or forge:oil and
 * silently widen unrelated recipes.
 */
const registerTFGFluidNameTags = (event) => {

	const SLURRY_PATTERN = /^(dirty|filtered|clean)_.+_slurry$/
	const EXTRA_MATERIALS = ['mercury']

	const missingFluid = []
	let tagged = 0

	forEachMaterial(material => {
		// Material names are Java strings and may or may not carry the namespace.
		const fullName = String(material.getName())
		const name = fullName.indexOf(':') === -1 ? fullName : fullName.split(':')[1]

		const slurry = SLURRY_PATTERN.exec(name)
		if (slurry === null && EXTRA_MATERIALS.indexOf(name) === -1) return

		// Chained on purpose: Rhino compares wrapped Java objects against null
		// unreliably, so a missing fluid is detected by the throw instead.
		let fluid
		try {
			fluid = String(material.getFluid().getFluidType().toString())
		}
		catch (exception) {
			missingFluid.push(name)
			return
		}

		event.add(`forge:${name}`, fluid)
		if (slurry !== null) {
			event.add('tfg:slurries', fluid)
			event.add(`tfg:${slurry[1]}_slurries`, fluid)
		}
		tagged++
	})

	console.info(`[TFG fluid name tags] tagged ${tagged} fluids`)
	if (missingFluid.length !== 0) {
		console.info(`[TFG fluid name tags] no fluid form, skipped: ${missingFluid.join(', ')}`)
	}
}
