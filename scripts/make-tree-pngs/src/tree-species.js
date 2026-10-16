/**
 * Species presets for the tree PNG generator.
 *
 * ez-tree (@dgreenheck/ez-tree) only ships 4 bark textures (birch, oak, pine,
 * willow) and 4 leaf textures (ash, aspen, oak, pine). There is no native
 * "baobab" or "sequoia" texture set. Instead, each entry below picks the
 * closest bark/leaf texture and tunes the structural parameters (trunk
 * thickness, branching angles, crown height, gnarliness, tint, etc.) so the
 * generated silhouette reads as that species' *category* rather than being a
 * literal, photo-accurate rendering of it.
 *
 * Every numeric leaf value in `options` can be given either as:
 *   - a fixed value (string, boolean, or single number), or
 *   - a `[min, max]` range, which is resolved to a random value in that
 *     range for every generated variant.
 *
 * `tint` / `color` fields given as a `[colorA, colorB]` pair (two 0xRRGGBB
 * integers) are resolved by interpolating the RGB channels, not by treating
 * the hex numbers as a numeric range (which would produce unrelated colors).
 *
 * `camera` holds rough framing hints (relative to the original script's
 * d = 15 default) since species vary hugely in scale, from a squat Joshua
 * tree to a towering sequoia. These are estimates, not measured from a
 * render (this environment has no GPU/browser to preview with) -- nudge
 * `distanceScale` / `heightScale` per species if a render comes out cropped
 * or too small in frame.
 */

// ---------------------------------------------------------------------------
// Pure helpers (no three.js / ez-tree dependency -- safe to unit test with
// plain Node, since the actual Tree.generate() call needs a browser to load
// its bundled textures).
// ---------------------------------------------------------------------------

export function randomRange(min, max) {
  return Math.random() * (max - min) + min;
}

function isColorKey(key) {
  return key === 'tint' || key === 'color';
}

function isRangePair(node) {
  return (
    Array.isArray(node) &&
    node.length === 2 &&
    typeof node[0] === 'number' &&
    typeof node[1] === 'number'
  );
}

/**
 * Interpolates between two 0xRRGGBB colors by channel, avoiding the "random
 * hex integer in [min,max]" trap, which can land on an unrelated hue.
 */
export function lerpColor(colorA, colorB, t) {
  const ar = (colorA >> 16) & 0xff, ag = (colorA >> 8) & 0xff, ab = colorA & 0xff;
  const br = (colorB >> 16) & 0xff, bg = (colorB >> 8) & 0xff, bb = colorB & 0xff;
  const r = Math.round(ar + (br - ar) * t);
  const g = Math.round(ag + (bg - ag) * t);
  const b = Math.round(ab + (bb - ab) * t);
  return (r << 16) | (g << 8) | b;
}

/**
 * Recursively walks a species' `options` config and resolves every
 * `[min, max]` range (or color pair) to a concrete randomized value for one
 * variant. Fixed values (strings, booleans, plain numbers) pass through
 * unchanged. The result has the same shape as TreeOptions, so it can be fed
 * straight into `TreeOptions.copy()`.
 */
export function resolveRangeNode(node, key) {
  if (isRangePair(node)) {
    return isColorKey(key) ? lerpColor(node[0], node[1], Math.random()) : randomRange(node[0], node[1]);
  }
  if (Array.isArray(node)) {
    // Non-range array: a discrete list of choices, pick one at random.
    return node[Math.floor(Math.random() * node.length)];
  }
  if (node !== null && typeof node === 'object') {
    const out = {};
    for (const k of Object.keys(node)) {
      out[k] = resolveRangeNode(node[k], k);
    }
    return out;
  }
  return node;
}

/**
 * Resolves one randomized options object for a species, ready to pass to
 * `TreeOptions.copy()`. Does not set `seed` -- the caller controls that so
 * each variant gets a distinct deterministic seed.
 */
export function resolveSpeciesOptions(species) {
  return resolveRangeNode(species.options, null);
}

// ---------------------------------------------------------------------------
// Species presets
// ---------------------------------------------------------------------------

export const TREE_SPECIES = {
  Oak: {
    options: {
      type: 'deciduous',
      bark: {
        type: 'oak',
        tint: [0xf2dcae, 0xe0c28a],
        textureScale: { x: 1, y: [7, 10] },
      },
      branch: {
        levels: 3,
        angle: { 1: [48, 60], 2: [38, 50], 3: [28, 40] },
        children: { 0: [8, 10], 1: [4, 6], 2: [3, 4] },
        length: { 0: [40, 52], 1: [24, 33], 2: [14, 20], 3: [6, 9] },
        radius: { 0: [2.6, 3.4], 1: [0.6, 0.8], 2: [0.6, 0.8], 3: [1.0, 1.3] },
        start: { 1: [0.3, 0.4], 2: [0.08, 0.15], 3: [0, 0.05] },
        taper: { 0: [0.65, 0.78], 1: [0.35, 0.5], 2: [0.6, 0.75], 3: [0.7, 0.8] },
        gnarliness: { 0: [-0.08, 0.05], 1: [0.1, 0.22], 2: [-0.1, 0.05], 3: [0.05, 0.15] },
        twist: { 0: [-0.3, 0.1], 1: [0.2, 0.5], 2: 0, 3: 0 },
      },
      leaves: {
        type: 'oak',
        billboard: 'double',
        angle: [28, 42],
        count: [9, 13],
        start: [0.1, 0.2],
        size: [4, 5.2],
        sizeVariance: 0.7,
        tint: [0xb9d26f, 0x9cc24e],
        alphaTest: 0.5,
      },
    },
  },

  Maple: {
    options: {
      type: 'deciduous',
      bark: {
        type: 'oak',
        tint: [0xcbb49a, 0xb79c7d],
        textureScale: { x: 1, y: [6, 9] },
      },
      branch: {
        levels: 3,
        angle: { 1: [50, 65], 2: [42, 55], 3: [32, 45] },
        children: { 0: [8, 11], 1: [4, 6], 2: [3, 5] },
        length: { 0: [34, 44], 1: [18, 25], 2: [10, 15], 3: [4, 7] },
        radius: { 0: [2.0, 2.6], 1: [0.5, 0.7], 2: [0.5, 0.65], 3: [0.8, 1.0] },
        start: { 1: [0.32, 0.42], 2: [0.1, 0.18], 3: [0, 0.06] },
        taper: { 0: [0.65, 0.76], 1: [0.4, 0.52] },
        gnarliness: { 0: [-0.05, 0.08], 1: [0.08, 0.18] },
      },
      leaves: {
        // Autumn maple color: resolved per-variant between gold and deep red.
        type: 'oak',
        billboard: 'double',
        angle: [26, 38],
        count: [10, 14],
        start: [0.12, 0.22],
        size: [3.6, 4.6],
        sizeVariance: 0.7,
        tint: [0xd98a3d, 0xb8432a],
        alphaTest: 0.5,
      },
    },
  },

  Elm: {
    options: {
      // Vase-shaped: narrow initial angle so branches rise before fanning
      // out wide higher up.
      type: 'deciduous',
      bark: {
        type: 'oak',
        tint: [0xd8c49e, 0xc3a97d],
        textureScale: { x: 1, y: [7, 9] },
      },
      branch: {
        levels: 3,
        angle: { 1: [30, 40], 2: [55, 68], 3: [45, 58] },
        children: { 0: [6, 8], 1: [6, 8], 2: [3, 5] },
        length: { 0: [36, 46], 1: [26, 34], 2: [14, 20], 3: [5, 8] },
        radius: { 0: [2.0, 2.6], 1: [0.55, 0.75], 2: [0.5, 0.65], 3: [0.8, 1.0] },
        start: { 1: [0.45, 0.55], 2: [0.1, 0.18], 3: [0, 0.05] },
        taper: { 0: [0.6, 0.72], 1: [0.4, 0.55] },
        gnarliness: { 0: [-0.05, 0.1], 1: [0.1, 0.2] },
      },
      leaves: {
        type: 'oak',
        billboard: 'double',
        angle: [26, 36],
        count: [9, 13],
        start: [0.12, 0.2],
        size: [3.4, 4.3],
        sizeVariance: 0.7,
        tint: [0xa8c472, 0x8fb559],
        alphaTest: 0.5,
      },
    },
  },

  Birch: {
    options: {
      type: 'deciduous',
      bark: {
        type: 'birch',
        tint: [0xf4f0e6, 0xe8e2d2],
        textureScale: { x: 1, y: [1, 2] },
      },
      branch: {
        levels: 3,
        angle: { 1: [35, 48], 2: [40, 52], 3: [32, 44] },
        children: { 0: [6, 8], 1: [4, 6], 2: [3, 4] },
        // Tall clear trunk before the crown starts.
        length: { 0: [42, 54], 1: [16, 22], 2: [9, 13], 3: [4, 6] },
        radius: { 0: [1.1, 1.5], 1: [0.3, 0.45], 2: [0.25, 0.35], 3: [0.4, 0.55] },
        start: { 1: [0.5, 0.62], 2: [0.12, 0.2], 3: [0, 0.05] },
        taper: { 0: [0.6, 0.72], 1: [0.4, 0.55] },
        gnarliness: { 0: [0, 0.1], 1: [0.05, 0.15] },
      },
      leaves: {
        type: 'aspen',
        billboard: 'double',
        angle: [30, 40],
        count: [14, 20],
        start: [0.14, 0.22],
        size: [2.6, 3.4],
        sizeVariance: 0.7,
        tint: [0xcdd87a, 0xaecb55],
        alphaTest: 0.5,
      },
    },
  },

  Aspen: {
    options: {
      type: 'deciduous',
      bark: {
        type: 'birch',
        tint: [0xffffff, 0xf2f2ea],
        textureScale: { x: 1, y: 1 },
      },
      branch: {
        levels: 2,
        angle: { 1: [42, 54], 2: [55, 68] },
        children: { 0: [8, 12], 1: [5, 7] },
        length: { 0: [62, 78], 1: [15, 21], 2: [8, 12] },
        radius: { 0: [0.95, 1.3], 1: [0.45, 0.65] },
        start: { 1: [0.55, 0.68], 2: [0.03, 0.08] },
        taper: { 0: [0.65, 0.78], 1: [0.1, 0.2] },
        gnarliness: { 0: [0, 0.1], 1: [-0.05, 0.1] },
        force: { strength: [0.015, 0.03] },
      },
      leaves: {
        type: 'aspen',
        billboard: 'double',
        angle: [30, 42],
        count: [17, 24],
        start: [0.12, 0.2],
        size: [3, 3.9],
        sizeVariance: 0.7,
        tint: [0xe8e050, 0xc9d23a],
        alphaTest: 0.5,
      },
    },
  },

  Willow: {
    options: {
      // Weeping willow: a downward "force" bends the long, thin secondary
      // branches so they droop and cascade instead of growing upward.
      type: 'deciduous',
      bark: {
        type: 'willow',
        tint: [0xe6ddc8, 0xd4c7a8],
        textureScale: { x: 1, y: [1, 2] },
      },
      branch: {
        levels: 3,
        angle: { 1: [55, 70], 2: [70, 85], 3: [75, 90] },
        children: { 0: [8, 11], 1: [5, 7], 2: [3, 5] },
        length: { 0: [30, 38], 1: [26, 34], 2: [20, 28], 3: [10, 16] },
        radius: { 0: [1.6, 2.1], 1: [0.35, 0.5], 2: [0.2, 0.3], 3: [0.12, 0.18] },
        start: { 1: [0.3, 0.42], 2: [0.15, 0.25], 3: [0.1, 0.2] },
        taper: { 0: [0.6, 0.72], 1: [0.5, 0.65], 2: [0.55, 0.68], 3: [0.6, 0.72] },
        gnarliness: { 1: [0.15, 0.3], 2: [0.2, 0.35], 3: [0.15, 0.3] },
        twist: { 1: [0.1, 0.25], 2: [0.1, 0.25] },
        force: {
          direction: { x: 0, y: -1, z: 0 },
          strength: [0.04, 0.08],
        },
      },
      leaves: {
        type: 'aspen',
        billboard: 'double',
        angle: [18, 28],
        count: [20, 28],
        start: [0.08, 0.16],
        size: [2.0, 2.6],
        sizeVariance: 0.6,
        tint: [0xcddb6a, 0xaec94a],
        alphaTest: 0.5,
      },
    },
  },

  Eucalyptus: {
    options: {
      type: 'deciduous',
      bark: {
        type: 'birch',
        tint: [0xd8ddd2, 0xc4ccc0],
        textureScale: { x: 1, y: [1, 2] },
      },
      branch: {
        levels: 2,
        angle: { 1: [38, 50], 2: [45, 58] },
        children: { 0: [6, 9], 1: [4, 6] },
        length: { 0: [55, 70], 1: [18, 25], 2: [10, 15] },
        radius: { 0: [1.1, 1.5], 1: [0.35, 0.5] },
        start: { 1: [0.5, 0.62], 2: [0.1, 0.18] },
        taper: { 0: [0.62, 0.74], 1: [0.4, 0.55] },
        // Slightly leaning/crooked trunk, true to eucalyptus habit.
        gnarliness: { 0: [0.05, 0.15], 1: [0.1, 0.2] },
      },
      leaves: {
        type: 'aspen',
        billboard: 'double',
        angle: [24, 34],
        count: [10, 15],
        start: [0.14, 0.24],
        size: [2.4, 3.2],
        sizeVariance: 0.7,
        tint: [0xb9c7c9, 0x9fb0b5],
        alphaTest: 0.5,
      },
    },
  },

  Banyan: {
    options: {
      // Wide sprawling canopy with gnarled, twisting limbs (standing in for
      // the aerial-root tangle real banyans grow).
      type: 'deciduous',
      bark: {
        type: 'oak',
        tint: [0xd3bd98, 0xbfa37a],
        textureScale: { x: 1, y: [6, 9] },
      },
      branch: {
        levels: 3,
        angle: { 1: [62, 78], 2: [60, 75], 3: [55, 70] },
        children: { 0: [10, 14], 1: [7, 10], 2: [5, 7] },
        length: { 0: [26, 34], 1: [22, 30], 2: [16, 22], 3: [8, 12] },
        radius: { 0: [2.6, 3.4], 1: [0.6, 0.85], 2: [0.5, 0.7], 3: [0.7, 0.9] },
        start: { 1: [0.25, 0.35], 2: [0.08, 0.16], 3: [0, 0.06] },
        taper: { 0: [0.6, 0.72], 1: [0.45, 0.6] },
        gnarliness: { 0: [0.15, 0.3], 1: [0.2, 0.35], 2: [0.15, 0.3] },
        twist: { 1: [0.15, 0.3], 2: [0.1, 0.25] },
      },
      leaves: {
        type: 'oak',
        billboard: 'double',
        angle: [30, 44],
        count: [11, 15],
        start: [0.1, 0.18],
        size: [4.2, 5.4],
        sizeVariance: 0.7,
        tint: [0x7fae5a, 0x5f9645],
        alphaTest: 0.5,
      },
    },
  },

  Baobab: {
    options: {
      // Massive stubby trunk with minimal taper, crown crammed near the top
      // only -- the iconic "upside-down tree" silhouette.
      type: 'deciduous',
      bark: {
        type: 'oak',
        tint: [0xc9b896, 0xb09e78],
        textureScale: { x: [0.6, 0.9], y: [3, 5] },
      },
      branch: {
        levels: 2,
        angle: { 1: [55, 72], 2: [45, 62] },
        children: { 0: [5, 8], 1: [4, 6] },
        length: { 0: [14, 20], 1: [7, 11], 2: [4, 7] },
        radius: { 0: [3.6, 5.0], 1: [0.5, 0.75], 2: [0.3, 0.45] },
        start: { 1: [0.8, 0.92], 2: [0.15, 0.3] },
        taper: { 0: [0.2, 0.35], 1: [0.4, 0.55] },
        gnarliness: { 0: [0.1, 0.25], 1: [0.15, 0.3] },
      },
      leaves: {
        type: 'oak',
        billboard: 'double',
        angle: [30, 42],
        count: [4, 7],
        start: [0.3, 0.5],
        size: [2.6, 3.4],
        sizeVariance: 0.6,
        tint: [0x9aa06a, 0x838a52],
        alphaTest: 0.5,
      },
    },
  },

  Joshua: {
    options: {
      // Short, contorted trunk and limbs with sparse spiky tufts of
      // "leaves" at the branch tips, like a Joshua tree's yucca crown.
      type: 'evergreen',
      bark: {
        type: 'pine',
        tint: [0xcda47a, 0xb98f5f],
        textureScale: { x: 1, y: [1, 2] },
      },
      branch: {
        levels: 2,
        angle: { 1: [55, 75], 2: [45, 70] },
        children: { 0: [3, 5], 1: [2, 4] },
        length: { 0: [10, 16], 1: [6, 10], 2: [3, 5] },
        radius: { 0: [0.9, 1.3], 1: [0.4, 0.6], 2: [0.2, 0.35] },
        start: { 1: [0.3, 0.5], 2: [0.5, 0.7] },
        taper: { 0: [0.3, 0.45], 1: [0.35, 0.5] },
        gnarliness: { 0: [0.3, 0.5], 1: [0.35, 0.55], 2: [0.3, 0.5] },
        twist: { 0: [0.2, 0.4], 1: [0.2, 0.4] },
      },
      leaves: {
        type: 'pine',
        billboard: 'double',
        angle: [40, 55],
        count: [6, 10],
        start: [0.75, 0.9],
        size: [0.8, 1.3],
        sizeVariance: 0.4,
        tint: [0x9fae5f, 0x8a9a4a],
        alphaTest: 0.5,
      },
    },
  },

  Cedar: {
    options: {
      type: 'evergreen',
      bark: {
        type: 'pine',
        tint: [0x9fae92, 0x7f9078],
        textureScale: { x: 1, y: [1, 2] },
      },
      branch: {
        levels: 2,
        angle: { 1: [55, 70], 2: [50, 65] },
        children: { 0: [14, 18], 1: [4, 6] },
        length: { 0: [22, 30], 1: [10, 16], 2: [4, 7] },
        radius: { 0: [1.0, 1.4], 1: [0.3, 0.45], 2: [0.15, 0.25] },
        start: { 1: [0.15, 0.3], 2: [0.1, 0.2] },
        taper: { 0: [0.65, 0.75], 1: [0.5, 0.65] },
        gnarliness: { 0: [0.03, 0.08], 1: [0.05, 0.12] },
        force: { strength: [-0.01, 0.01] },
      },
      leaves: {
        type: 'pine',
        billboard: 'double',
        angle: [14, 20],
        count: [14, 20],
        start: [0.05, 0.12],
        size: [2.2, 3],
        sizeVariance: 0.3,
        tint: [0x7a9e6e, 0x5f8a5a],
        alphaTest: 0.4,
      },
    },
  },

  Spruce: {
    options: {
      // Narrow dense spire: a single trunk level with many short,
      // close-packed needle clusters, like the pine_large reference preset.
      type: 'evergreen',
      bark: {
        type: 'pine',
        tint: [0xaebcc4, 0x8fa0ab],
        textureScale: { x: 1, y: 1 },
      },
      branch: {
        levels: 1,
        angle: { 1: [18, 28] },
        children: { 0: [90, 120], 1: [2, 4] },
        length: { 0: [55, 75], 1: [20, 30] },
        radius: { 0: [0.9, 1.3], 1: [0.25, 0.4] },
        start: { 1: [0.2, 0.35] },
        gnarliness: { 0: [0.03, 0.08], 1: [0.05, 0.1] },
      },
      leaves: {
        type: 'pine',
        billboard: 'double',
        angle: [12, 18],
        count: [16, 22],
        start: [0.05, 0.1],
        size: [2, 2.8],
        sizeVariance: 0.25,
        tint: [0x6f93a8, 0x5a7f8f],
        alphaTest: 0.3,
      },
    },
    camera: { distanceScale: 1.8, heightScale: 1.6 },
  },

  Sequoia: {
    options: {
      // Towering, very thick trunk with a comparatively small crown that
      // only begins well above half the tree's height.
      type: 'evergreen',
      bark: {
        type: 'pine',
        tint: [0xcf8f6a, 0xb97050],
        textureScale: { x: 1, y: [1, 2] },
      },
      branch: {
        levels: 2,
        angle: { 1: [25, 35], 2: [30, 40] },
        children: { 0: [10, 14], 1: [5, 8] },
        length: { 0: [70, 95], 1: [18, 26], 2: [8, 14] },
        radius: { 0: [3.0, 4.5], 1: [0.5, 0.8], 2: [0.3, 0.5] },
        start: { 1: [0.55, 0.7], 2: [0.1, 0.2] },
        taper: { 0: [0.6, 0.75], 1: [0.5, 0.65] },
        gnarliness: { 0: [0, 0.08], 1: [0.03, 0.1] },
      },
      leaves: {
        type: 'pine',
        billboard: 'double',
        angle: [14, 20],
        count: [12, 18],
        start: [0.4, 0.55],
        size: [2, 2.8],
        sizeVariance: 0.3,
        tint: [0x6f9e6a, 0x587f55],
        alphaTest: 0.4,
      },
    },
  },
};

export const SPECIES_NAMES = Object.keys(TREE_SPECIES);
