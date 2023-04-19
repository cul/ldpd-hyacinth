
/**
 * @namespace OpenSeadragon.FeaturedRegion
 * @classdesc The namespace for OpenSeadragon.FeaturedRegion plugin.
 *
 */

OpenSeadragon.FeaturedRegion = {
  iiifRegionToImageRectangle: function(iiifRegion) {
    const defaultRect = [0, 0, 768, 768];
    if (iiifRegion.match(/(\d+,){0,3}\d+/)) {
      const segments = iiifRegion.split(',').map((x) => parseInt(x));
      return new OpenSeadragon.Rect(...segments.concat(defaultRect.slice(segments.length)));
    }
    return new OpenSeadragon.Rect(...defaultRect);
  },
  imageRectToIiifRegion: function(rect) {
    return [rect.x, rect.y, rect.width, rect.height].map(x => Math.floor(x)).join(',');
  },
  getOrCreateFeaturedRegionOverlayElement: function() {
    return document.getElementById('featured-region-overlay') || function () {
      const featuredRegionElement = document.createElement('div');
      featuredRegionElement.id = 'featured-region-overlay';
      featuredRegionElement.classList.add('featured-region');
      return featuredRegionElement;
    }();
  },
  drawRegion: function(tiledImage, viewer, featuredRegionWidget) {
    if (featuredRegionWidget && featuredRegionWidget.value.match(/\d+,\d+,\d+,\d+/)) {
      const viewportRect = tiledImage.imageToViewportRectangle(OpenSeadragon.FeaturedRegion.iiifRegionToImageRectangle(featuredRegionWidget.value));
      var overlay;
      if (overlay = viewer.getOverlayById('featured-region-overlay')) {
        overlay.update({location: viewportRect});
        overlay.drawHTML(viewer.overlaysContainer, viewer.viewport );
      } else viewer.addOverlay(OpenSeadragon.FeaturedRegion.getOrCreateFeaturedRegionOverlayElement(), viewportRect);
    }
  },
  initializeFeaturedRegionFor: function(osdViewer, widgetId = 'featured-region') {
    return function(event) {
      // tile-loaded; run once just to get ref to TiledImage source
      const tiledImage = event.tiledImage;
      const featuredRegionWidget = document.getElementById(widgetId)
      if (featuredRegionWidget) {
        OpenSeadragon.FeaturedRegion.drawRegion(tiledImage, osdViewer, featuredRegionWidget);
        const modeControls = document.getElementsByName('featured-region-mode');
        const regionSelector = OpenSeadragon.FeaturedRegion.MouseTracker.for(osdViewer, tiledImage, featuredRegionWidget, modeControls);
      }
    }
  },
  for: function(osdViewer) {
    osdViewer.addOnceHandler('tile-loaded', OpenSeadragon.FeaturedRegion.initializeFeaturedRegionFor(osdViewer));
  },
  MouseTracker: class {
    static for(osdViewer, tiledImage, featuredRegionWidget, modeControls) {
      var overlayElement = OpenSeadragon.FeaturedRegion.getOrCreateFeaturedRegionOverlayElement();
      const selectorArgs = { regionOp: 'hide', viewer: osdViewer, tiledImage: tiledImage, element: overlayElement };
      // do not fire an input event from the value handler; listen for external change events
      selectorArgs.valueHandler = function(value) { featuredRegionWidget.value = value };
      featuredRegionWidget.addEventListener('input', function(event) { regionSelector.resetToRegion(event.target.value) });
      overlayElement.classList.add('featured-region-hide');
      const regionSelector = new OpenSeadragon.FeaturedRegion.RegionSelector(selectorArgs);
      // handle the region operation class and viewer changes and set user data
      for (var i = 0; i < modeControls.length; i++) {
        modeControls[i].addEventListener('input', function(event) { regionSelector.setRegionOp(event.target.value) });
      }

      new OpenSeadragon.MouseTracker({
        element: overlayElement,
        preProcessEventHandler: regionSelector.preProcessEventHandler.bind(regionSelector),
        pressHandler: regionSelector.pressHandler.bind(regionSelector),
        dragHandler: regionSelector.dragHandler.bind(regionSelector),
        releaseHandler: regionSelector.releaseHandler.bind(regionSelector)
      });
    }
  },
  RegionSelector: class {
    constructor(args) {
      this.viewer = args.viewer;
      this.tiledImage = args.tiledImage;
      this.element = args.element;
      this.opData = {};
      this.regionOp = args.regionOp;
      this.valueHandler = args.valueHandler;
      this.minimumImageRegion = new OpenSeadragon.Rect(0,0,768,768);
    }

    static closestVertex(pt, rect) {
      const bottomEdge = (pt.y <= rect.y + (rect.height/2)) ? 0 : 2;
      const rightEdge = (pt.x <= rect.x + (rect.width/2)) ? 0 : 1;
      return [0, 1, 3, 2][bottomEdge | rightEdge]; // vertex clockwise numbers arranged here to support quick index
    }

    dragToResize(event) {
      const viewport = this.viewer.viewport;
      const { overlay, vertex, minPointsLength } = this.opData;
      const viewportBounds = viewport.getBounds();

      const overlayUpdate = overlay.getBounds(viewport);
      var elementOffset = viewport.viewportToViewerElementCoordinates(overlayUpdate.getTopLeft());
      var pulledVertex = viewport.viewerElementToViewportCoordinates(event.position.plus(elementOffset));
      var refPt, viewportCorner, maxSide, width, height, side;
      switch(vertex) {
      case 0:
        refPt = overlayUpdate.getBottomRight();
        maxSide = Math.min(refPt.x, refPt.y);
        width = refPt.x - pulledVertex.x;
        height = refPt.y - pulledVertex.y;
        side = Math.max(minPointsLength, Math.min(maxSide, Math.max(width, height)));
        overlayUpdate.x = refPt.x - side;
        overlayUpdate.y = refPt.y - side;
        break;
      case 1:
        refPt = overlayUpdate.getBottomLeft();
        viewportCorner = viewportBounds.getTopRight();
        maxSide = Math.min(viewportCorner.x - refPt.x, refPt.y);
        width = pulledVertex.x - refPt.x;
        height = refPt.y - pulledVertex.y;
        side = Math.max(minPointsLength, Math.min(maxSide, Math.max(width, height)));
        overlayUpdate.y = refPt.y - side;
        break;
      case 2:
        refPt = overlayUpdate.getTopLeft();
        viewportCorner = viewportBounds.getBottomRight();
        maxSide = Math.min(viewportCorner.x - refPt.x, viewportCorner.y - refPt.y);
        width = pulledVertex.x - refPt.x;
        height = pulledVertex.y - refPt.y;
        side = Math.max(minPointsLength, Math.min(maxSide, Math.max(width, height)));
        break;
      case 3:
        refPt = overlayUpdate.getTopRight();
        viewportCorner = viewportBounds.getBottomLeft();
        maxSide = Math.min(refPt.x, viewportCorner.y - refPt.y);
        width = refPt.x - pulledVertex.x;
        height = pulledVertex.y - refPt.y;
        side = Math.max(minPointsLength, Math.min(maxSide, Math.max(width, height)));
        overlayUpdate.x = refPt.x - side;
        break;
      default:
        return null;
      }
      overlayUpdate.width = overlayUpdate.height = side;
      return overlayUpdate;
    }
    dragToMove(event) {
      // drag the overlay
      const viewport = this.viewer.viewport;
      const overlay = this.opData.overlay;
      var delta = viewport.deltaPointsFromPixels(event.delta);
      // recalculate current bounds
      var overlayRect = overlay.getBounds(viewport);
      var updateLocation = overlayRect.translate(delta);
      // sometimes the translate adjusts a dimension by a pixel, but we only want the location changed
      updateLocation.width = updateLocation.height = overlayRect.width;
      return updateLocation;
    }
    setRegionOp(value) {
      const toggleOps = ['move', 'resize', 'hide', 'show'];
      if (toggleOps.includes(value)) toggleOps.splice(toggleOps.indexOf(value), 1);
      const classList = this.element.classList;
      toggleOps.forEach(function(op) { classList.toggle('featured-region-' + op, false) });
      classList.toggle('featured-region-' + value, true);

      if (value == 'resize' || value == 'move') {
        this.viewer.setMouseNavEnabled(false);
      }
      if (value == 'show' || value == 'hide') {
        this.viewer.setMouseNavEnabled(true);
      }
      this.regionOp = value;
    }
    preProcessEventHandler(eventInfo) {
      const regionOp = this.regionOp;
      switch (eventInfo.eventType) {
        case 'pointerdown':
        case 'pointerup':
        case 'contextmenu':
          eventInfo.preventDefault = (regionOp == 'move' || regionOp == 'resize');
          break;
        default:
          break;
      }
    }
    pressHandler(event) {
      if (this.regionOp != 'move' && this.regionOp != 'resize') return;
      const viewport = this.viewer.viewport;
      const overlay = this.viewer.getOverlayById(event.eventSource.element);
      const overlayBounds = overlay.getBounds(viewport);
      const imageBounds = this.tiledImage.getBounds();
      const topLeft = viewport.viewportToViewerElementCoordinates(overlayBounds.getTopLeft());
      const startPos = viewport.viewerElementToViewportCoordinates(topLeft.plus(event.position));
      this.opData = {
        overlay: overlay,
        imageBounds: imageBounds,
        vertex: OpenSeadragon.FeaturedRegion.RegionSelector.closestVertex(startPos, overlayBounds),
        minPointsLength: viewport.imageToViewportRectangle(this.minimumImageRegion).width
      };
    }
    dragHandler(event) {
      var regionLocationUpdate;
      const regionOp = this.regionOp;
      switch(regionOp) {
      case 'move':
        if (this.opData.overlay) regionLocationUpdate = this.dragToMove(event);
        break;
      case 'resize':
        if (this.opData.overlay) regionLocationUpdate = this.dragToResize(event);
        break;
      }
      if (!regionLocationUpdate) return;
      const viewer = this.viewer;
      const tiledImage = this.tiledImage;
      const { overlay, imageBounds } = this.opData;
      const inImage = imageBounds.containsPoint(regionLocationUpdate.getTopLeft()) &&
                      imageBounds.containsPoint(regionLocationUpdate.getBottomRight());
      if (!inImage) return;
      overlay.update({ location: regionLocationUpdate});
      overlay.drawHTML(this.viewer.overlaysContainer, this.viewer.viewport );
      const imageRect = tiledImage.viewportToImageRectangle(regionLocationUpdate);
      this.valueHandler(OpenSeadragon.FeaturedRegion.imageRectToIiifRegion(imageRect));
    }
    releaseHandler(event) {
      this.opData = {};
    }
    resetToRegion(regionValue) {
      const regionRect = OpenSeadragon.FeaturedRegion.iiifRegionToImageRectangle(regionValue);
      const regionLocationUpdate = this.tiledImage.imageToViewportRectangle(regionRect);
      const overlay = this.viewer.getOverlayById(this.element);
      overlay.update({ location: regionLocationUpdate});
      overlay.drawHTML(this.viewer.overlaysContainer, this.viewer.viewport );
    }
  },
  dismissableBootstrapAlert: function(viewer, message, type = 'info', classes = []) {
    const alertId = 'osd-dismissable-alert';
    const prevOverlay = viewer.getOverlayById(alertId);
    if (prevOverlay) {
      viewer.removeOverlay(alertId);
      prevOverlay.destroy();
    }
    const alert = document.createElement('div');
    alert.className = ['alert osd-alert alert-' + type].concat(classes).join(' ');
    alert.role = 'alert';
    alert.id = alertId;

    const alertBody = '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' + '<p>' + message + '</p>';
    alert.innerHTML = alertBody;
    const mouseNav = viewer.isMouseNavEnabled();
    viewer.setMouseNavEnabled(false);
    viewer.addOverlay(alert, viewer.viewport.getBounds().getCenter(), OpenSeadragon.Placement.CENTER);
    const close = alert.getElementsByTagName('button')[0];
    if (close) close.addEventListener('click', function() { viewer.removeOverlay(alertId); viewer.setMouseNavEnabled(mouseNav); });
    return alert;
  }
};
