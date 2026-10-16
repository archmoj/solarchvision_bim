import * as THREE from 'three';
import { Tree } from '@dgreenheck/ez-tree';
import { TREE_SPECIES, SPECIES_NAMES, resolveSpeciesOptions } from './tree-species.js';

const renderWidth = 800;
const renderHeight = 800;

// How many randomized variants to generate per species. Each variant uses a
// different seed plus a fresh random draw from that species' parameter
// ranges (see tree-species.js), so trees of the same species still differ
// from one another while keeping the same overall silhouette/identity.
const VARIANTS_PER_SPECIES = 3;

// CAMERAS
var camera = new THREE.PerspectiveCamera(35, renderWidth / renderHeight, 1, 10000);
var d = 50;
camera.position.set(0, 0, d * 3);
camera.up.set(0, 0, 1);
camera.lookAt(0, d, 0); // Focus the camera on the center of the trunk


// RENDERER
var renderer = new THREE.WebGLRenderer({
	preserveDrawingBuffer: true, // required to support .toDataURL()
	antialias: true,
	alpha: true,
});

renderer.setClearColor(0x000000, 0);
renderer.setPixelRatio(1);
renderer.setSize(renderWidth, renderHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFShadowMap;

document.getElementById('app').appendChild(renderer.domElement);

const appContainer = document.getElementById('app');
appContainer.appendChild(renderer.domElement);
renderer.domElement.style.border = '2px solid green';


var scene = new THREE.Scene();

// Add basic lighting so the generated tree is visible upon export
const ambientLight = new THREE.AmbientLight(0xffffff, 5.0);
scene.add(ambientLight);
const dirLight = new THREE.DirectionalLight(0xffffff, 5.0);
dirLight.position.set(0, 0, 100);
dirLight.castShadow = true;
scene.add(dirLight);

let tree = null;
var requestID;

/**
 * Builds the flat list of render jobs: every species repeated
 * VARIANTS_PER_SPECIES times, each with its own seed.
 */
function buildJobQueue() {
	const jobs = [];
	for (const speciesName of SPECIES_NAMES) {
		for (let variant = 1; variant <= VARIANTS_PER_SPECIES; variant++) {
			jobs.push({
				speciesName,
				variant,
				// Keep seeds distinct across the whole run so no two jobs,
				// even across species, happen to regenerate identical geometry.
				seed: Math.floor(Math.random() * 1_000_000),
			});
		}
	}
	return jobs;
}

let jobQueue = buildJobQueue();
// duplicate first job to by pass first frame bug
jobQueue = [jobQueue[0]].concat(jobQueue);

let jobIndex = -1;

function render() {
	jobIndex++;

	if (jobIndex >= jobQueue.length) return;

	const { speciesName, variant, seed } = jobQueue[jobIndex];
	const speciesConfig = TREE_SPECIES[speciesName];

	// Remove the previous tree (if any) before generating the next one.
	if (tree) {
		scene.remove(tree);
	}

	// A fresh Tree() starts from ez-tree's default TreeOptions, so applying
	// this species' (partial) overrides on top never leaks parameters left
	// over from the previous species' job.
	tree = new Tree();
	tree.options.copy(resolveSpeciesOptions(speciesConfig));
	tree.options.seed = seed;

	scene.add(tree);

	// 3. Generate geometry safely
	tree.generate();

	// 4. Loop through all generated parts (trunk, leaves, etc.) to apply shadows
	tree.traverse((child) => {
		if (child.isMesh) {
			child.castShadow = true;
			child.receiveShadow = true;
		}
	});

	renderer.render(scene, camera);

	requestID = requestAnimationFrame(render);
	cancelAnimationFrame(requestID);

	if(jobIndex != 0) { // skip first frame which has a bug
		let filename = `${speciesName}_${variant}.png`;
		downloadCanvas(renderer.domElement, filename);
	}

	setTimeout(() => {
		requestID = requestAnimationFrame(render);
	}, 100);
}

// RENDER LOOP
render();

function downloadCanvas (canvas, filename) {
	var a = document.createElement('a');
	a.style.cssText = 'display: none';
	a.href = canvas.toDataURL('image/png')
	a.download = filename;

	document.body.appendChild(a);
	a.click();
	a.parentNode.removeChild(a);
}
