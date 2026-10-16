import * as THREE from 'three';
import { Tree } from '@dgreenheck/ez-tree';

const renderWidth = 800;
const renderHeight = 800;

// CAMERAS
var camera = new THREE.PerspectiveCamera(35, renderWidth / renderHeight, 1, 10000);
var d = 15;
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

let tree = new Tree();

scene.add(tree);
var requestID;
var frame = -1;

function randomRange(min, max) {
  return Math.random() * (max - min) + min;
}

function render() {
	frame++;

	if(frame > 10) return;

	tree.options.seed = frame;
	tree.options.branch.levels = 3; // 3 levels of geometry generation

	tree.options.branch.length[0] = randomRange(10, 20);
	tree.options.branch.radius[0] = randomRange(0.5, 1.0);

	tree.options.branch.length[1] = randomRange(5, 10);
	tree.options.branch.radius[1] = randomRange(0.25, 0.5);

	tree.options.branch.length[2] = randomRange(2.5, 5);
	tree.options.branch.radius[2] = randomRange(0.125, 0.25);

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

	// skip first frame
	if(frame !== 0) {
		let filename = frame + ".png";
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
