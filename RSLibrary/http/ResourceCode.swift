enum ResourceCode{
    case success
    case server_ERROR
    case e8000  //WIFI NOT Connect
    case e9993  //USER ERROR
    case e9994  //HTTP Error
    case e9995  //Connection Timeout
    case e9996  //Socket Timeout
    case e9997  //UnKnow Host
    case e9998  //Parsing Error
    case e9999  //UnKnown Error
    
    
    func message() -> String{
        switch self{
            case .success:
                return "성공"
            case .server_ERROR:
                return "server_error"
            case .e8000:
                return "[8000]인터넷이 연결되어있지않습니다."
            case .e9993:
                return "server_error"
            case .e9994:
                return "[9994]데이터 통신에 실패하였습니다"
            case .e9995:
                return "[9995]서버 연결시간 초과"
            case .e9996:
                return "[9996]서버 연결시간 초과"
            case .e9997:
                return "[9997]서버를 찾을수 없습니다."
            case .e9998:
                return "[9998]데이터 변환시 오류발생"
            case .e9999:
                return "[9999]알수없는 오류"
        }
        
    }
}
