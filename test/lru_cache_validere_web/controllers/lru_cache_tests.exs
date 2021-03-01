defmodule LruCacheValidereWeb.CacheControllerTest do
    use LruCacheValidereWeb.ConnCase

    test "#should add a valid key and value pair and be able to retrieve it with 200 OK", %{conn: conn} do
      delete(conn, "/delete")
      conn = put(conn, "/put", [key: "1", value: "test"])
      assert json_response(conn, :ok) == %{"message" => "ok"}
      conn = get(conn, "/get?key=1")
      assert json_response(conn, :ok) == %{"value" => "test"}
    end

    test "#should return bad request from the server when parameters are invalid with 500 Error", %{conn: conn} do
        delete(conn, "/delete")
        conn = get(conn, "/get?")
        assert json_response(conn, :bad_request) == %{"error" => "Invalid parameters provided."}
        conn = put(conn, "/put")
        assert json_response(conn, :bad_request) == %{"error" => "Invalid parameters provided."}
      end
  
    test "#should return not found for a key that does not exist in the cache with 200 OK", %{conn: conn} do
      delete(conn, "/delete")
      put(conn, "/put", [key: "1", value: "value1"])
      conn = get(conn, "/get?key=1")
      assert json_response(conn, :ok) == %{"value" => "value1"}
      conn = get(conn, "/get?key=2")
      assert json_response(conn, :not_found) == %{"value" => "not_found"}
    end
  
    test "#should remove least recently used key when new key is added at maximum capacity (of 4) with 200 OK", %{conn: conn} do
      delete(conn, "/delete")
      put(conn, "/put", [key: "1", value: "test1"])
      put(conn, "/put", [key: "2", value: "test2"])
      put(conn, "/put", [key: "3", value: "test3"])
      put(conn, "/put", [key: "4", value: "test4"])
      put(conn, "/put", [key: "5", value: "test5"])
      put(conn, "/put", [key: "6", value: "test6"])
      conn = get(conn, "/get?key=1")
      assert json_response(conn, :not_found) == %{"value" => "not_found"}
      conn = get(conn, "/get?key=2")
      assert json_response(conn, :not_found) == %{"value" => "not_found"}
      conn = get(conn, "/get_state")
      assert json_response(conn, :ok) == %{"state" => ["3", "4", "5", "6"]}
    end
  
    test "#should return up to date keys in the cache with 200 OK", %{conn: conn} do
      delete(conn, "/delete")
      put(conn, "/put", [key: "1", value: "test1"])
      put(conn, "/put", [key: "2", value: "test2"])
      put(conn, "/put", [key: "3", value: "test3"])
      put(conn, "/put", [key: "4", value: "test4"])
      put(conn, "/put", [key: "5", value: "test5"])
      conn = get(conn, "/get_state")
      assert json_response(conn, :ok) == %{"state" => ["1", "2", "3", "4", "5"]}
      put(conn, "/put", [key: "1", value: "test1"])
      conn = get(conn, "/get_state")
      assert json_response(conn, :ok) == %{"state" => ["2", "3", "4", "5", "1"]}
      conn = get(conn, "/get?key=3")
      assert json_response(conn, :ok) == %{"value" => "test3"}
      conn = get(conn, "/get_state")
      assert json_response(conn, :ok) == %{"state" => ["2", "4", "5", "1", "3"]}
    end
  
    test "#should delete the cache with 200 OK", %{conn: conn} do
      delete(conn, "/delete")
      put(conn, "/put", [key: "1", value: "test1"])
      put(conn, "/put", [key: "2", value: "test2"])
      put(conn, "/put", [key: "3", value: "test3"])
      delete(conn, "/delete")
      conn = get(conn, "/get?key=1")
      assert json_response(conn, :not_found) == %{"value" => "not_found"}
      conn = get(conn, "/get?key=2")
      assert json_response(conn, :not_found) == %{"value" => "not_found"}
      conn = get(conn, "/get?key=3")
      assert json_response(conn, :not_found) == %{"value" => "not_found"}
      conn = get(conn, "/get_state")
      assert json_response(conn, :ok) == %{"state" => []}
    end 
  end
  