import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:workout_prediction_system_mobile/features/home/models/water_balance.dart';
import 'package:workout_prediction_system_mobile/features/home/providers/water_balance_provider.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class WaterBalanceScreen extends ConsumerStatefulWidget {
  const WaterBalanceScreen({super.key});

  @override
  ConsumerState<WaterBalanceScreen> createState() => _WaterBalanceScreenState();
}

class _WaterBalanceScreenState extends ConsumerState<WaterBalanceScreen> {
  final TextEditingController _customAmountController = TextEditingController();
  WaterCupSize _selectedCupSize = WaterCupSize.medium;
  double _customAmount = 0;
  bool _isEditingGoal = false;
  final TextEditingController _goalController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _handleAddWater(double amount) {
    ref.read(waterBalanceNotifierProvider.notifier).addWater(amount);
  }

  void _handleRemoveEntry(String entryId) {
    ref.read(waterBalanceNotifierProvider.notifier).removeWaterEntry(entryId);
  }

  void _handleUpdateGoal(double newGoal) {
    ref.read(waterBalanceNotifierProvider.notifier).updateWaterGoal(newGoal);
    setState(() {
      _isEditingGoal = false;
    });
  }

  void _handleUpdateDefaultCupSize(WaterCupSize cupSize) {
    ref
        .read(waterBalanceNotifierProvider.notifier)
        .updateDefaultCupSize(cupSize);
    setState(() {
      _selectedCupSize = cupSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final waterBalanceAsync = ref.watch(waterBalanceNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Water Balance',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: waterBalanceAsync.when(
        data: (waterBalance) {
          // Set the selected cup size from the data
          if (_selectedCupSize != waterBalance.defaultCupSize) {
            _selectedCupSize = waterBalance.defaultCupSize;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWaterProgressCard(waterBalance),
                SizedBox(height: 24.h),
                _buildAddWaterSection(waterBalance),
                SizedBox(height: 24.h),
                _buildWaterHistorySection(waterBalance),
              ],
            ),
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C896)),
            ),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading water data: $error',
                    style: TextUtils.kBodyText(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(waterBalanceNotifierProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C896),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildWaterProgressCard(WaterBalance waterBalance) {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3A86FF).withOpacity(0.2),
            const Color(0xFF3A86FF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A86FF).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF3A86FF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Water Intake',
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(fontSize: 18.sp, color: Colors.white),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        waterBalance.formattedTotalWater,
                        style: TextUtils.kHeading(context).copyWith(
                          fontSize: 28.sp,
                          color: const Color(0xFF3A86FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / ${waterBalance.formattedGoalWater}',
                        style: TextUtils.kBodyText(
                          context,
                        ).copyWith(fontSize: 16.sp, color: Colors.white70),
                      ),
                      SizedBox(width: 8.w),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isEditingGoal = true;
                            _goalController.text =
                                waterBalance.waterGoal.toString();
                          });
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.white70,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A86FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.water_drop,
                    color: const Color(0xFF3A86FF),
                    size: 32.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (_isEditingGoal)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: 'Enter new goal (ml)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    final newGoal = double.tryParse(_goalController.text);
                    if (newGoal != null && newGoal > 0) {
                      _handleUpdateGoal(newGoal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditingGoal = false;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: waterBalance.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF3A86FF),
                    ),
                    minHeight: 12.h,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(waterBalance.progress * 100).toInt()}% completed',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    Text(
                      'Goal: ${waterBalance.formattedGoalWater}',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAddWaterSection(WaterBalance waterBalance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Water',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(fontSize: 18.sp, color: Colors.white),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Text(
              'Default Cup Size:',
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(width: 8.w),
            DropdownButton<WaterCupSize>(
              value: _selectedCupSize,
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              underline: Container(height: 1, color: const Color(0xFF3A86FF)),
              onChanged: (WaterCupSize? newValue) {
                if (newValue != null) {
                  _handleUpdateDefaultCupSize(newValue);
                }
              },
              items:
                  WaterCupSize.values.map<DropdownMenuItem<WaterCupSize>>((
                    WaterCupSize size,
                  ) {
                    return DropdownMenuItem<WaterCupSize>(
                      value: size,
                      child: Text(size.label),
                    );
                  }).toList(),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            for (final cupSize in WaterCupSize.values)
              if (cupSize != WaterCupSize.custom) _buildWaterCupButton(cupSize),
            _buildCustomWaterButton(),
          ],
        ),
        if (_selectedCupSize == WaterCupSize.custom)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: 'Enter amount (ml)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _customAmount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed:
                      _customAmount > 0
                          ? () {
                            _handleAddWater(_customAmount);
                            _customAmountController.clear();
                            setState(() {
                              _customAmount = 0;
                            });
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWaterCupButton(WaterCupSize cupSize) {
    return InkWell(
      onTap: () => _handleAddWater(cupSize.amount),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3A86FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                _selectedCupSize == cupSize
                    ? const Color(0xFF3A86FF)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cupSize.icon, color: const Color(0xFF3A86FF), size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              '${cupSize.amount.toInt()} ml',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomWaterButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCupSize = WaterCupSize.custom;
          _handleUpdateDefaultCupSize(WaterCupSize.custom);
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3A86FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                _selectedCupSize == WaterCupSize.custom
                    ? const Color(0xFF3A86FF)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: const Color(0xFF3A86FF), size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              'Custom',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterHistorySection(WaterBalance waterBalance) {
    final sortedEntries = List<WaterEntry>.from(waterBalance.entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s History',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(fontSize: 18.sp, color: Colors.white),
        ),
        SizedBox(height: 16.h),
        if (sortedEntries.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'No water entries for today',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return _buildWaterEntryItem(entry);
            },
          ),
      ],
    );
  }

  Widget _buildWaterEntryItem(WaterEntry entry) {
    final formattedTime = DateFormat('HH:mm').format(entry.timestamp);
    String amountText = '${entry.amount.toInt()} ml';
    if (entry.amount >= 1000) {
      amountText = '${(entry.amount / 1000).toStringAsFixed(1)} L';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF3A86FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop,
              color: const Color(0xFF3A86FF),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Added at $formattedTime',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _handleRemoveEntry(entry.id),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[300],
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
