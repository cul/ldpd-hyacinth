export default PictureInPictureToggle;
export type Player = any;
/**
 * @typedef { import('./player').default } Player
 */
/**
 * Toggle Picture-in-Picture mode
 *
 * @extends Button
 */
declare class PictureInPictureToggle extends Button {
    /**
     * Creates an instance of this class.
     *
     * @param {Player} player
     *        The `Player` that this class should be attached to.
     *
     * @param {Object} [options]
     *        The key/value store of player options.
     *
     * @listens Player#enterpictureinpicture
     * @listens Player#leavepictureinpicture
     */
    constructor(player: any, options?: any);
    /**
     * Enables or disables button based on document.pictureInPictureEnabled property value
     * or on value returned by player.disablePictureInPicture() method.
     */
    handlePictureInPictureEnabledChange(): void;
    /**
     * Handles enterpictureinpicture and leavepictureinpicture on the player and change control text accordingly.
     *
     * @param {Event} [event]
     *        The {@link Player#enterpictureinpicture} or {@link Player#leavepictureinpicture} event that caused this function to be
     *        called.
     *
     * @listens Player#enterpictureinpicture
     * @listens Player#leavepictureinpicture
     */
    handlePictureInPictureChange(event?: Event): void;
    /**
     * This gets called when an `PictureInPictureToggle` is "clicked". See
     * {@link ClickableComponent} for more detailed information on what a click can be.
     *
     * @param {Event} [event]
     *        The `keydown`, `tap`, or `click` event that caused this function to be
     *        called.
     *
     * @listens tap
     * @listens click
     */
    handleClick(event?: Event): void;
}
import Button from "../button.js";
//# sourceMappingURL=picture-in-picture-toggle.d.ts.map