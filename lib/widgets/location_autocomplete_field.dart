import 'package:flutter/material.dart';
import 'package:travel_buddy/services/google_maps_service.dart';

class LocationAutocompleteField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final Function(String) onLocationSelected;
  final TextEditingController? controller;
  final bool restrictToCountry;
  final String countryCode;
  final List<String>? types;
  final String? hintText;

  const LocationAutocompleteField({
    Key? key,
    required this.label,
    this.initialValue,
    required this.onLocationSelected,
    this.controller,
    this.restrictToCountry = false,
    this.countryCode = 'in',
    this.types,
    this.hintText,
  }) : super(key: key);

  @override
  _LocationAutocompleteFieldState createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  late TextEditingController _controller;
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value) async {
    if (value.length < 2) {
      setState(() {
        _showSuggestions = false;
        _predictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    try {
      final predictions = await GoogleMapsService.getPlacePredictions(
        value,
        restrictToCountry: widget.restrictToCountry,
        countryCode: widget.countryCode,
        types: widget.types,
      );

      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _predictions = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText ?? 'Search for a location',
            prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                if (_controller.text.isNotEmpty && !_isLoading)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onLocationSelected('');
                      setState(() {
                        _showSuggestions = false;
                        _predictions = [];
                      });
                    },
                  ),
              ],
            ),
          ),
          onChanged: _onTextChanged,
          onTap: () {
            if (_predictions.isNotEmpty) {
              setState(() {
                _showSuggestions = true;
              });
            }
          },
        ),
        if (_showSuggestions && (_isLoading || _predictions.isNotEmpty))
          Container(
            margin: EdgeInsets.only(top: 4),
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:
                _isLoading
                    ? Container(
                      height: 60,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.orange,
                              strokeWidth: 2,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Searching...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            prediction.icon,
                            color: Colors.orange,
                            size: 20,
                          ),
                          title: Text(
                            prediction.mainText,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              prediction.secondaryText.isNotEmpty
                                  ? Text(
                                    prediction.secondaryText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                  : null,
                          onTap: () {
                            _controller.text = prediction.description;
                            widget.onLocationSelected(prediction.description);
                            setState(() {
                              _showSuggestions = false;
                            });
                            _focusNode.unfocus();
                          },
                        );
                      },
                    ),
          ),
      ],
    );
  }
}
