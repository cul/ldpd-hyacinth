export default ErrorDisplay;
export type Player = import('./player').default;
/**
 * @typedef { import('./player').default } Player
 */
/**
 * A display that indicates an error has occurred. This means that the video
 * is unplayable.
 *
 * @extends ModalDialog
 */
declare class ErrorDisplay extends ModalDialog {
    /**
     * Creates an instance of this class.
     *
     * @param  {Player} player
     *         The `Player` that this class should be attached to.
     *
     * @param  {Object} [options]
     *         The key/value store of player options.
     */
    constructor(player: Player, options?: any);
    /**
     * Gets the localized error message based on the `Player`s error.
     *
     * @return {string}
     *         The `Player`s error message localized or an empty string.
     */
    content(): string;
}
import ModalDialog from "./modal-dialog";
//# sourceMappingURL=error-display.d.ts.map