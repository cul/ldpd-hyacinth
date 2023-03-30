export default checkVolumeSupport;
export type Player = import('../../player').default;
export type Component = import('../../component').default;
/**
 * @typedef { import('../../player').default } Player
 * @typedef { import('../../component').default } Component
 */
/**
 * Check if volume control is supported and if it isn't hide the
 * `Component` that was passed  using the `vjs-hidden` class.
 *
 * @param {Component} self
 *        The component that should be hidden if volume is unsupported
 *
 * @param {Player} player
 *        A reference to the player
 *
 * @private
 */
declare function checkVolumeSupport(self: Component, player: Player): void;
//# sourceMappingURL=check-volume-support.d.ts.map