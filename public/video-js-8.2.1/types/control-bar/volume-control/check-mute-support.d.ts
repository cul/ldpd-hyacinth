export default checkMuteSupport;
export type Player = import('../../player').default;
export type Component = import('../../component').default;
/**
 * @typedef { import('../../player').default } Player
 * @typedef { import('../../component').default } Component
 */
/**
 * Check if muting volume is supported and if it isn't hide the mute toggle
 * button.
 *
 * @param {Component} self
 *        A reference to the mute toggle button
 *
 * @param {Player} player
 *        A reference to the player
 *
 * @private
 */
declare function checkMuteSupport(self: Component, player: Player): void;
//# sourceMappingURL=check-mute-support.d.ts.map