/**
 * @typedef { import('./time').TimeRange } TimeRange
 */
/**
 * Compute the percentage of the media that has been buffered.
 *
 * @param {TimeRange} buffered
 *        The current `TimeRanges` object representing buffered time ranges
 *
 * @param {number} duration
 *        Total duration of the media
 *
 * @return {number}
 *         Percent buffered of the total duration in decimal form.
 */
export function bufferedPercent(buffered: TimeRange, duration: number): number;
export type TimeRange = import('./time').TimeRange;
//# sourceMappingURL=buffer.d.ts.map