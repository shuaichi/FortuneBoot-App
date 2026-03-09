import 'package:hjproject/login/model/login_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
// 替换为您实际的路径

part 'include_request.g.dart'; // 保持和您原来一样

@RestApi(baseUrl: "/fortune/include")
abstract class IncludeService {
  factory IncludeService(Dio dio, {String baseUrl}) = _IncludeService;

  @GET("/{groupId}/getTotalLiabilities")
  Future<HJResponse> getTotalLiabilities(@Path("groupId") int groupId);

  @GET("/{groupId}/getFortuneAssetsLiabilities")
  Future<HJResponse> getFortuneAssetsLiabilities(@Path("groupId") int groupId);

  // 注意：参数名保持了您原有的 tradeTimeStartTime 和 tradeTimeEndTime
  @GET("/getBillStatistics")
  Future<HJResponse> getBillStatistics(
      @Query("bookId") int bookId,
      @Query("tradeTimeStartTime") String tradeTimeStartTime,
      @Query("tradeTimeEndTime") String tradeTimeEndTime,
      );

  @GET("/getCategoryIncome")
  Future<HJResponse> getCategoryIncome(
      @Query("bookId") int bookId,
      @Query("startDate") String startDate,
      @Query("endDate") String endDate,
      );

  @GET("/getCategoryExpense")
  Future<HJResponse> getCategoryExpense(
      @Query("bookId") int bookId,
      @Query("startDate") String startDate,
      @Query("endDate") String endDate,
      );

  @GET("/getIncomeTrends")
  Future<HJResponse> getIncomeTrends(
      @Query("bookId") int bookId,
      @Query("timeGranularity") int timeGranularity,
      @Query("timePoint") String timePoint,
      );

  @GET("/getExpenseTrends")
  Future<HJResponse> getExpenseTrends(
      @Query("bookId") int bookId,
      @Query("timeGranularity") int timeGranularity,
      @Query("timePoint") String timePoint,
      );

  // === 以下为看板新引入的标签接口，请添加到您的类中 ===
  @GET("/getTagExpense")
  Future<HJResponse> getTagExpense(
      @Query("bookId") int bookId,
      @Query("startDate") String startDate,
      @Query("endDate") String endDate,
      );

  @GET("/getTagIncome")
  Future<HJResponse> getTagIncome(
      @Query("bookId") int bookId,
      @Query("startDate") String startDate,
      @Query("endDate") String endDate,
      );
}