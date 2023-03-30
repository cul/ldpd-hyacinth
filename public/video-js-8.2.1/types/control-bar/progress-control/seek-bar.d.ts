export default SeekBar;
export type Player = import('../../player').default;
export type Event = any;
/**
 * Seek bar and container for the progress bars. Uses {@link PlayProgressBar}
 * as its `bar`.
 *
 * @extends Slider
 */
declare class SeekBar extends Slider {
    /**
     * Sets the event handlers
     *
     * @private
     */
    private setEventHandlers_;
    /**
     * This function updates the play progress bar and accessibility
     * attributes to whatever is passed in.
     *
     * @param {Event} [event]
     *        The `timeupdate` or `ended` event that caused this to run.
     *
     * @listens Player#timeupdate
     *
     * @return {number}
     *          The current percent at a number from 0-1
     */
    update(event?: any): number;
    updateInterval: number;
    enableIntervalHandler_: (e: any) => void;
    disableIntervalHandler_: (e: any) => void;
    toggleVisibility_(e: any): void;
    enableInterval_(): void;
    disableInterval_(e: any): void;
    /**
     * Create the `Component`'s DOM element
     *
     * @return {Element}
     *         The element that was created.
     */
    createEl(): Element;
    percent_: any;
    currentTime_: any;
    duration_: any;
    /**
     * Prevent liveThreshold from causing seeks to seem like they
     * are not happening from a user perspective.
     *
     * @param {number} ct
     *        current time to seek to
     */
    userSeek_(ct: number): void;
    /**
     * Get the value of current time but allows for smooth scrubbing,
     * when player can't keep up.
     *
     * @return {number}
     *         The current time value to display
     *
     * @private
     */
    private getCurrentTime_;
    /**
     * Get the percentage of media played so far.
     *
     * @return {number}
     *         The percentage of media played so far (0 to 1).
     */
    getPercent(): number;
    /**
     * Handle mouse down on seek bar
     *
     * @param {Event} event
     *        The `mousedown` event that caused this to run.
     *
     * @listens mousedown
     */
    handleMouseDown(event: any): void;
    videoWasPlaying: boolean;
    /**
     * Handle mouse move on seek bar
     *
     * @param {Event} event
     *        The `mousemove` event that caused this to run.
     * @param {boolean} mouseDown this is a flag that should be set to true if `handleMouseMove` is called directly. It allows us to skip things that should not happen if coming from mouse down but should happen on regular mouse move handler. Defaults to false
     *
     * @listens mousemove
     */
    handleMouseMove(event: any, mouseDown?: boolean): void;
    /**
     * Handle mouse up on seek bar
     *
     * @param {Event} event
     *        The `mouseup` event that caused this to run.
     *
     * @listens mouseup
     */
    handleMouseUp(event: any): void;
    /**
     * Move more quickly fast forward for keyboard-only users
     */
    stepForward(): void;
    /**
     * Move more quickly rewind for keyboard-only users
     */
    stepBack(): void;
    /**
     * Toggles the playback state of the player
     * This gets called when enter or space is used on the seekbar
     *
     * @param {Event} event
     *        The `keydown` event that caused this function to be called
     *
     */
    handleAction(event: any): void;
    /**
     * Called when this SeekBar has focus and a key gets pressed down.
     * Supports the following keys:
     *
     *   Space or Enter key fire a click event
     *   Home key moves to start of the timeline
     *   End key moves to end of the timeline
     *   Digit "0" through "9" keys move to 0%, 10% ... 80%, 90% of the timeline
     *   PageDown key moves back a larger step than ArrowDown
     *   PageUp key moves forward a large step
     *
     * @param {Event} event
     *        The `keydown` event that caused this function to be called.
     *
     * @listens keydown
     */
    handleKeyDown(event: any): void;
    dispose(): void;
}
import Slider from "../../slider/slider.js";
//# sourceMappingURL=seek-bar.d.ts.map