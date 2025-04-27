import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:workout_prediction_system_mobile/features/progress/providers/health_providers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class WorkoutRecorderScreen extends ConsumerStatefulWidget {
  const WorkoutRecorderScreen({super.key});

  @override
  ConsumerState<WorkoutRecorderScreen> createState() =>
      _WorkoutRecorderScreenState();
}

class _WorkoutRecorderScreenState extends ConsumerState<WorkoutRecorderScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().addHours(1);
  String _selectedWorkoutType = 'RUNNING';
  final TextEditingController _caloriesController = TextEditingController(
    text: '300',
  );
  final TextEditingController _distanceController = TextEditingController(
    text: '0',
  );
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _workoutTypes = [
    'RUNNING',
    'WALKING',
    'CYCLING',
    'SWIMMING',
    'STRENGTH_TRAINING',
    'YOGA',
    'PILATES',
    'HIIT',
    'DANCE',
    'BASKETBALL',
    'SOCCER',
    'TENNIS',
    'OTHER',
  ];

  @override
  void dispose() {
    _caloriesController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Record Workout',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextUtils.kBodyText(context).copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Date picker
                      _buildSectionTitle('Date'),
                      _buildDatePicker(),
                      SizedBox(height: 24.h),

                      // Workout type dropdown
                      _buildSectionTitle('Workout Type'),
                      _buildWorkoutTypeDropdown(),
                      SizedBox(height: 24.h),

                      // Start time and end time
                      _buildSectionTitle('Workout Duration'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimePicker('Start Time', _startTime, (
                              time,
                            ) {
                              setState(() => _startTime = time);
                            }),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildTimePicker('End Time', _endTime, (
                              time,
                            ) {
                              setState(() => _endTime = time);
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Duration: ${_calculateDuration()} minutes',
                        style: TextUtils.kBodyText(context).copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Calories burned
                      _buildSectionTitle('Calories Burned'),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          hintText: 'Enter calories burned',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          suffixText: 'kcal',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter calories burned';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Distance (optional)
                      _buildSectionTitle('Distance (optional)'),
                      TextFormField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[800],
                          hintText: 'Enter distance',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          suffixText: 'meters',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32.h),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.surface,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Save Workout',
                            style: TextUtils.kSubHeading(context).copyWith(
                              fontSize: 16.sp,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextUtils.kSubHeading(context).copyWith(fontSize: 16.sp),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Theme.of(context).colorScheme.secondary,
                  onPrimary: Theme.of(context).colorScheme.surface,
                  surface: Colors.grey[850]!,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
              style: TextUtils.kBodyText(context),
            ),
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWorkoutType,
          isExpanded: true,
          dropdownColor: Colors.grey[800],
          items:
              _workoutTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type.replaceAll('_', ' '),
                    style: TextUtils.kBodyText(context),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedWorkoutType = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextUtils.kBodyText(
            context,
          ).copyWith(color: Colors.grey[400], fontSize: 12.sp),
        ),
        SizedBox(height: 4.h),
        InkWell(
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).colorScheme.secondary,
                      onPrimary: Theme.of(context).colorScheme.surface,
                      surface: Colors.grey[850]!,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedTime != null) {
              onTimeSelected(selectedTime);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context), style: TextUtils.kBodyText(context)),
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _calculateDuration() {
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // If end time is earlier than start time, assume it's the next day
    final duration =
        endDateTime.isBefore(startDateTime)
            ? endDateTime.add(const Duration(days: 1)).difference(startDateTime)
            : endDateTime.difference(startDateTime);

    return duration.inMinutes.toString();
  }

  Future<void> _submitWorkout() async {
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Create workout start and end times
        final startDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _startTime.hour,
          _startTime.minute,
        );

        final endDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _endTime.hour,
          _endTime.minute,
        );

        // If end time is earlier than start time, assume it's the next day
        final adjustedEndDateTime =
            endDateTime.isBefore(startDateTime)
                ? endDateTime.add(const Duration(days: 1))
                : endDateTime;

        // Get calories and distance values
        final calories = int.tryParse(_caloriesController.text) ?? 0;
        final distance = int.tryParse(_distanceController.text) ?? 0;

        // Save workout to health service
        final healthService = ref.read(healthServiceProvider);
        final success = await healthService.writeWorkout(
          workoutType: _selectedWorkoutType,
          startTime: startDateTime,
          endTime: adjustedEndDateTime,
          calories: calories,
          distance: distance > 0 ? distance : null,
        );

        if (success) {
          // Refresh workouts provider to show the new workout
          ref.refresh(
            workoutsProvider((
              startDate: DateTime.now().subtract(const Duration(days: 30)),
              endDate: DateTime.now(),
            )),
          );

          // Show success message and pop back
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Workout saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _errorMessage =
                'Failed to save workout. Please check your health app permissions.';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}

// Extension to add hours to TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay addHours(int hours) {
    final totalMinutes = this.hour * 60 + this.minute + hours * 60;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }
}
